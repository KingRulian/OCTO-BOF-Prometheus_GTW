#! /usr/bin/env bash

## Export functions:
#   - create_metric <metric_name> <metric_type> <metric_description>
#   - add_metrics <metric_name> <matric_value> <metrics_labels>(comma separated with escaped \")
#   - push_metrics

_PUSH_GTW_JOB_NAME="${PUSH_GTW_JOB_NAME:-deprecated_images}"
_PUSH_GTW_ENDPOINT="${PUSH_GTW_ENDPOINT:-prometheus-gtw.monitoring.svc:9091}"

_metrics_file="/tmp/metrics" 
> $_metrics_file

function set_job() {
    _PUSH_GTW_JOB_NAME=${1}
}

function set_gtw_endpoint() {
    _PUSH_GTW_ENDPOINT=${1}
}

function create_metric() {
    metric_name=$1
    metric_type=$2
    metric_description=$3
    cat << EOF >> $_metrics_file
# TYPE $metric_name $metric_type
# HELP $metric_name $metric_description
EOF
}

function add_metrics() {
    metric_name=$1
    metric_value=$2
    shift; shift;
    metric_labels=$@
    cat << EOF >> $_metrics_file
${metric_name}{${metric_labels}} $metric_value
EOF
}

function push_metrics() {
    curl -v --data-binary @"${_metrics_file}" http://${_PUSH_GTW_ENDPOINT}/metrics/job/${_PUSH_GTW_JOB_NAME}
    if [ "$?" -ne "0" ]; then
        echo "[ERROR] push_metrics : Could not push metrics to http://${_PUSH_GTW_ENDPOINT}/metrics/job/${_PUSH_GTW_JOB_NAME}."
    fi
}