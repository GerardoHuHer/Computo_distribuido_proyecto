#!/bin/bash
# Script de prueba de carga para el middleware
# Dispara N peticiones concurrentes de create_rover, para forzar que
# el balanceador reparta trabajo entre las instancias disponibles de backend_rover.

MIDDLEWARE_URL="http://localhost:4002/api/gateway"
TOTAL_REQUESTS=${1:-50} # Número de peticiones, default 50
CONCURRENCY=${2:-10}    # Peticiones simultáneas, default 10

echo "Enviando $TOTAL_REQUESTS peticiones con concurrencia $CONCURRENCY..."
echo "Middleware: $MIDDLEWARE_URL"
echo "----------------------------------------"

enviar_peticion() {
  local i=$1
  local pos_x=$((RANDOM % 1000))
  local pos_y=$((RANDOM % 1000))

  respuesta=$(curl -s -X POST "$MIDDLEWARE_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"type\": \"rover\",
      \"action\": \"create_rover\",
      \"params\": {
        \"pos_x\": $pos_x,
        \"pos_y\": $pos_y,
        \"timestamp\": \"2026-09-13T12:00:00Z\"
      }
    }")

  echo "[$i] -> $respuesta"
}

export -f enviar_peticion
export MIDDLEWARE_URL

# seq genera 1..TOTAL_REQUESTS, xargs -P controla cuántos procesos corren a la vez
seq 1 "$TOTAL_REQUESTS" | xargs -I{} -P "$CONCURRENCY" bash -c 'enviar_peticion {}'

echo "----------------------------------------"
echo "Listo. Revisa los logs de cada backend_vehiculo1 para ver cómo se repartieron las peticiones:"
echo "  docker compose logs backend_vehiculo1"
echo ""
echo "También puedes ver el estado del clúster con:"
echo "  curl http://localhost:4002/api/debug/nodos"
