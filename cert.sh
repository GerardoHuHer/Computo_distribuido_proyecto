mkdir -p certs

# 1. Certificate Authority (CA)
openssl genrsa -out certs/ca.key 4096
openssl req -new -x509 -days 3650 -key certs/ca.key -out certs/ca.crt -subj "/CN=MyK8sCA"


# Se crea un certificado por cada tipo de backend
for svc in middleware backend-rover backend-central backend-inventario; do
  openssl genrsa -out certs/$svc.key 2048 # Creamos certificado llave para cada uno de los servicios
  openssl req -new -key certs/$svc.key -out certs/$svc.csr -subj "/CN=$svc"
  openssl x509 -req -days 365 -in certs/$svc.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/$svc.crt -extfile <(printf "subjectAltName=DNS:$svc,DNS:$svc.default.svc.cluster.local,DNS:*.$svc.default.svc.cluster.local\nextendedKeyUsage=serverAuth,clientAuth")
done

rm certs/*.csr certs/*.srl