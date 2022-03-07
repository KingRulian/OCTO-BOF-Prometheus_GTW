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

  openssl x509 -in "$_tls_crt_file" -noout -checkend $((_EXPIRATION_DAYS * 60 * 60 * 24))
  if [ $? -ne 0 ]; then
    echo "Error : asd"
  fi
}

function find_tls_secrets() {
  _tls_secrets=`kubectl get secrets -A -ojsonpath='{range .items[?(@.type=="kubernetes.io/tls")]}{.metadata.namespace}{" "}{.metadata.name}{" "}{.type}{" "}{.data.tls\.crt}{"\n"}{end}'`

  # echo "$_tls_secrets"
  for tls_secret in "${_tls_secrets[@]}"; do
    _ns=`echo ${tls_secret} | awk '{ print $1 }'`
    _name=`echo ${tls_secret} | awk '{ print $2 }'`
    _tls_b64=`echo ${tls_secret} | awk '{ print $3 }'`

    echo "NS=${_ns} - NAME=${_name} - TLS_B64=${_tls_b64}"
  done
}


function main() {
  set_job "tls_verify"
  create_metric "tls_infos" "gauge" "Information about TLS certs"
  find_tls_secrets
  # for tls_secret in "${_tls_secrets[@]}"; do
  #   _ns=`echo ${tls_secret} | awk '{ print $1 }'`
  #   _name=`echo ${tls_secret} | awk '{ print $2 }'`
  #   _tls_b64=`echo ${tls_secret} | awk '{ print $3 }'`

  #   echo "NS=${_ns} - NAME=${_name} - TLS_B64=${_tls_b64}"
  # done
}

main