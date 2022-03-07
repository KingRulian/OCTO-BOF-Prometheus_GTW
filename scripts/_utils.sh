#! /usr/bin/env bash

_local_date_args="-u -d" # Debian default
function _my_date() {
    _date=${@}
    docker run --rm --name=test debian date --date "${_date}" --utc '+%s' 2> /dev/null
    #date --date \"${_date}\" --utc '+%s' 2> /dev/null
    if [ "$?" -ne "0" ]; then
        echo "[ERROR] getDeltaTimeDays : Could not parse date '${_date}'" > /dev/stderr
    fi
}

function getDeltaTimeDays() {
    _toDate="${2:-`date '+%Y-%m-%dT%H:%M:%SZ'`}" # Default to now
    _fromDate="${1:?No Date Given}"
    _toDateSeconds=`_my_date "${_toDate}"`
    _fromDateSeconds=`_my_date "${_fromDate}"`

    echo "$(( (_fromDateSeconds - _toDateSeconds) / 24 / 3600 ))"
}
