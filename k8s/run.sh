#!/bin/sh

set -e

cd "$(dirname "$0")/.."

# verificación de que los certificados existan
[ -f certs/ca.crt ] || bash cert.sh

minikube status >/dev/null 2>&1 || minikube start --driver=docker --memory=6144

kubectl wait --for=condition=Ready node/minikube --timeout=180s

# Cargar imágenes dentro de minikube
for p in backend-central:central backend-rover:rover backend-inventario:inventario middleware:middleware; do
  minikube image build -t "${p%%:*}:latest" -f "${p##*:}/Dockerfile" .
done
minikube image build -t frontend:latest ./central_front

# Elimina secretos y los vuelve a cargar para evitar errores al correr los servicios
kubectl delete secret --all --ignore-not-found
kubectl delete configmap ssl-dist --ignore-not-found
bash k8s/secrets.sh

# Despliegue
kubectl apply -f k8s/rbac.yaml -f k8s/db-central.yaml -f k8s/db-rover.yaml -f k8s/db-inventario.yaml
kubectl apply -f k8s/middleware.yaml
kubectl wait --for=condition=Ready pod/middleware-0 --timeout=300s
kubectl apply -f k8s/backend-central.yaml -f k8s/backend-rover.yaml -f k8s/backend-inventario.yaml -f k8s/frontend.yaml

kubectl apply -f k8s/prometheus.yaml

kubectl get pods


