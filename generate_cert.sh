#! /usr/bin/env bash

mkdir -p my-safe-directory certs

echo "Creating certs that will expire in 365 days"
openssl genrsa -out my-safe-directory/ca.key 2048

chmod 400 my-safe-directory/ca.key

openssl req \
-new \
-x509 \
-config ca.cnf \
-key my-safe-directory/ca.key \
-out certs/ca.crt \
-days 365 \
-batch

echo "Creating certs that will expire in 30 days"
openssl genrsa -out my-safe-directory/ca2.key 2048

chmod 400 my-safe-directory/ca2.key

openssl req \
-new \
-x509 \
-config ca.cnf \
-key my-safe-directory/ca2.key \
-out certs/ca2.crt \
-days 30 \
-batch

ca=`cat certs/ca2.crt`
