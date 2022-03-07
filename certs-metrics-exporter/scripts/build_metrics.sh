#! /usr/bin/env bash

# Parse Script Path
_SCRIPTS_DIR="${0%/*}"
# Import metrics functions
source ${_SCRIPTS_DIR}/_metrics.sh
# Import _utils functions
source ${_SCRIPTS_DIR}/_utils.sh

LOG_FILE=`mktemp`
echo "[INFO] Log file location : ${LOG_FILE}"

function check_builds() {
    oc get buildconfig --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{" "}{.status.lastVersion}{"\n"}{end}' | grep -i '\-val' > /tmp/_bcs.txt

    cat /tmp/_bcs.txt | while read _ns _bc _version; do
        _buildName="${_bc}-${_version}"
        _buildInfos=`oc get build -n "${_ns}" "${_buildName}" -o jsonpath='{.status.completionTimestamp}{" "}{.status.phase}'`
        if [ "$?" -ne "0" ]; then
            echo "[ERROR] check_builds : Could not fetch build infos"
            add_metrics build_age "-1" namespace=\"${_ns}\",bc=\"${_bc}\",buildNumber=\"${_version}\",status=\"Unknown\"
            continue
        fi
        _buildDate=`echo ${_buildInfos} | awk '{print $1}'`
        _buildState=`echo ${_buildInfos} | awk '{print $2}'`

        _buildAge="$(getDeltaTimeDays ${_buildDate})" # In days
        add_metrics build_age "${_buildAge}" namespace=\"${_ns}\",bc=\"${_bc}\",buildNumber=\"${_version}\",status=\"${_buildState}\"
    done
}

{
set_job "builds_job"
create_metric "build_age" "gauge" "Age (en jours) des derniers builds et leur statut"
check_builds
push_metrics
} | tee -i ${LOG_FILE}
