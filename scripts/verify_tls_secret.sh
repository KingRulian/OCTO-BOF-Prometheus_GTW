#! /usr/bin/env bash

_LAUNCH_DIR=${0%/*}

source ${_LAUNCH_DIR}/_metrics.sh
source ${_LAUNCH_DIR}/_utils.sh

_EXPIRATION_DAYS=${EXPIRATION_DAYS:-30}

function verify_tls() {
  _secret_namespace="$1"
  _secret_name="$2"
  _tls_b64="$3"

  _tls_crt_file="/tmp/${_secret_namespace}-${secret_name}.crt"

  echo "${_tls_b64}" | base64 --decode > "${_tls_crt_file}"
  echo "[INFO] - Verifiying cert ${_secret_namespace}/${_secret_name} ..."
  openssl x509 -in "$_tls_crt_file" -noout -checkend "0"
  if [ $? -ne 0 ]; then
    echo "[ALERT] - Cert ${_secret_namespace}/${_secret_name} is expired"
    add_metrics "tls_infos" "-1" namespace=\"${_secret_namespace}\",name=\"${_secret_name}\",status=\"expired\"
    return
  fi
  openssl x509 -in "$_tls_crt_file" -noout -checkend "$((_EXPIRATION_DAYS * 60 * 60 * 24))"
  if [ $? -ne 0 ]; then
    echo "[ALERT] - Cert ${_secret_namespace}/${_secret_name} will expired in less than $_EXPIRATION_DAYS days"
    add_metrics "tls_infos" "#TODO" namespace=\"${_secret_namespace}\",name=\"${_secret_name}\",status=\"expire_soon\"

    return
  fi
  echo "[INFO] - Cert ${_secret_namespace}/${_secret_name} is OK"
  add_metrics "tls_infos" "#TODO" namespace=\"${_secret_namespace}\",name=\"${_secret_name}\",status=\"healthy\"

}

function find_tls_secrets() {
  kubectl get secrets -A -ojsonpath='{range .items[?(@.type=="kubernetes.io/tls")]}{.metadata.namespace}{" "}{.metadata.name}{" "}{.data.tls\.crt}{"\n"}{end}' > /tmp/_tls_secrets.txt

  echo "/tmp/_tls_secrets.txt"
}


function main() {
  set_job "tls_verify"
  create_metric "tls_infos" "gauge" "Information about TLS certs"
  cat `find_tls_secrets` | while read _ns _name _tls_b64; do
    verify_tls "$_ns" "$_name" "${_tls_b64}"
  done
  push_metrics
}

main