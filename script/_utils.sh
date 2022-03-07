#! /usr/bin/env bash

_local_date_args="-u -d" # Debian default
function _my_date() {
    _date=${1}
    # Mac variant image config date format
    date -j -f '%Y-%m-%d' "${_date}" '+%s' &> /dev/null 
    if [[ "$?" -eq "0" ]]; then
        _local_date_args="-j -f %Y-%m-%d"
    fi
    date ${_local_date_args} ${_date} '+%s' 2> /dev/null
    if [ "$?" -ne "0" ]; then
        echo "[ERROR] getDeltaTimeDays : Could not parse date '${_date}'" > /dev/stderr
    fi
}

function getDeltaTimeDays() {
    _toDate="${2:-`date '+%Y-%m-%dT%H:%M:%SZ'`}" # Default to now
    _fromDate="${1:?No Date Given}"
    
    _toDateSeconds=`_my_date "${_toDate}"`
    _fromDateSeconds=`_my_date "${_fromDate}"`

    echo "$(( (_toDateSeconds - _fromDateSeconds) / 24 / 3600 ))"
}