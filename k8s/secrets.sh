#!/bin/bash

set -e

# TLS a cada uno de los servicios
kubectl create secret generic tls-central \
  --from-file=ca.crt=certs/ca.crt \
  --from-file=tls.crt=certs/backend-central.crt \
  --from-file=tls.key=certs/backend-central.key

kubectl create secret generic tls-rover \
  --from-file=ca.crt=certs/ca.crt \
  --from-file=tls.crt=certs/backend-rover.crt \
  --from-file=tls.key=certs/backend-rover.key

kubectl create secret generic tls-inventario \
  --from-file=ca.crt=certs/ca.crt \
  --from-file=tls.crt=certs/backend-inventario.crt \
  --from-file=tls.key=certs/backend-inventario.key

kubectl create secret generic tls-middleware \
  --from-file=ca.crt=certs/ca.crt \
  --from-file=tls.crt=certs/middleware.crt \
  --from-file=tls.key=certs/middleware.key

# Cookie de Erlang, necesaria para que se conecten con libcluster
kubectl create secret generic erl-cookie --from-literal=cookie=cookie_compartida

# Creadenciales para conectarse a base de datos.
kubectl create secret generic db-central \
  --from-literal=user=user \
  --from-literal=password=password \
  --from-literal=db=db_central

kubectl create secret generic db-rover \
  --from-literal=user=user \
  --from-literal=password=password \
  --from-literal=db=db_vehiculo

kubectl create secret generic db-inventario \
  --from-literal=user=user \
  --from-literal=password=password \
  --from-literal=db=db_inventario

kubectl create secret generic phx-secret \
  --from-literal=secret_key_base="$(openssl rand -base64 64 | tr -d '\n')"

kubectl create configmap ssl-dist --from-file=k8s/ssl_dist.conf
