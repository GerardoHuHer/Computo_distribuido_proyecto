#!/bin/bash
# Script de prueba funcional: recorre todas las acciones expuestas por cada
# backend (rover, inventario, central) a través del único endpoint del
# Gateway (POST /api/gateway), más el endpoint de debug del middleware.
#
# Uso:
#   ./test_routes.sh
#   MIDDLEWARE_URL=http://localhost:4002 ./test_routes.sh

MIDDLEWARE_URL="${MIDDLEWARE_URL:-http://localhost:4002}"
GATEWAY_URL="$MIDDLEWARE_URL/api/gateway"
DEBUG_URL="$MIDDLEWARE_URL/api/debug/nodos"

HAS_JQ=0
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=1
fi

separador() {
  echo "----------------------------------------"
}

# $1 = descripción, $2 = payload JSON
llamar_gateway() {
  local descripcion="$1"
  local payload="$2"

  echo ">> $descripcion"
  echo "   payload: $payload"

  respuesta=$(curl -s -w '\n%{http_code}' -X POST "$GATEWAY_URL" \
    -H "Content-Type: application/json" \
    -d "$payload")

  cuerpo=$(echo "$respuesta" | sed '$d')
  codigo=$(echo "$respuesta" | tail -n1)

  echo "   http: $codigo"
  if [ "$HAS_JQ" -eq 1 ]; then
    echo "$cuerpo" | jq . 2>/dev/null || echo "   body: $cuerpo"
  else
    echo "   body: $cuerpo"
  fi
  separador

  # Se deja en $ULTIMO_CUERPO para que el llamador pueda extraer un id si lo necesita
  ULTIMO_CUERPO="$cuerpo"
}

# Extrae un campo del último cuerpo de respuesta (requiere jq)
extraer_id() {
  if [ "$HAS_JQ" -eq 1 ]; then
    echo "$ULTIMO_CUERPO" | jq -r '.id // empty' 2>/dev/null
  fi
}

echo "Probando contra: $MIDDLEWARE_URL"
if [ "$HAS_JQ" -eq 0 ]; then
  echo "(sugerencia: instala 'jq' para ver las respuestas formateadas y encadenar ids automáticamente)"
fi
separador

# ---------------------------------------------------------
# Debug del middleware (no pasa por RequestQueue)
# ---------------------------------------------------------
echo ">> GET /api/debug/nodos"
curl -s -w '\nhttp: %{http_code}\n' "$DEBUG_URL"
separador

# ---------------------------------------------------------
# Tipo no soportado (debe responder error, no colgarse)
# ---------------------------------------------------------
llamar_gateway "tipo no soportado (debe fallar rápido con error)" \
  '{"type":"clima","action":"foo","params":{}}'

# ---------------------------------------------------------
# Rover (backend_rover)
# ---------------------------------------------------------
llamar_gateway "rover: create_rover" \
  '{"type":"rover","action":"create_rover","params":{"pos_x":10,"pos_y":20,"timestamp":"2026-09-13T12:00:00Z"}}'
ROVER_ID=$(extraer_id)

llamar_gateway "rover: get_all_vehiculos" \
  '{"type":"rover","action":"get_all_vehiculos","params":{}}'

if [ -n "$ROVER_ID" ]; then
  llamar_gateway "rover: get_vehiculo (id=$ROVER_ID)" \
    "{\"type\":\"rover\",\"action\":\"get_vehiculo\",\"params\":{\"id\":\"$ROVER_ID\"}}"

  llamar_gateway "rover: move_vehiculo (id=$ROVER_ID)" \
    "{\"type\":\"rover\",\"action\":\"move_vehiculo\",\"params\":{\"id\":\"$ROVER_ID\",\"pos_x\":99,\"pos_y\":88}}"
else
  echo ">> rover: get_vehiculo / move_vehiculo omitidos (no se pudo extraer el id; instala jq)"
  separador
fi

llamar_gateway "rover: get_evento_random" \
  '{"type":"rover","action":"get_evento_random","params":{}}'

# ---------------------------------------------------------
# Inventario (backend_inventario)
# ---------------------------------------------------------
llamar_gateway "inventario: create_item" \
  '{"type":"inventario","action":"create_item","params":{"name":"Tornillos","description":"Caja de tornillos","cantidad":50,"prioridad":3}}'
ITEM_ID=$(extraer_id)

llamar_gateway "inventario: get_items" \
  '{"type":"inventario","action":"get_items","params":{}}'

if [ -n "$ITEM_ID" ]; then
  llamar_gateway "inventario: update_item (id=$ITEM_ID)" \
    "{\"type\":\"inventario\",\"action\":\"update_item\",\"params\":{\"id\":\"$ITEM_ID\",\"name\":\"Tornillos\",\"description\":\"Actualizado\",\"cantidad\":40,\"prioridad\":2}}"

  llamar_gateway "inventario: delete_item (id=$ITEM_ID)" \
    "{\"type\":\"inventario\",\"action\":\"delete_item\",\"params\":{\"id\":\"$ITEM_ID\"}}"
else
  echo ">> inventario: update_item / delete_item omitidos (no se pudo extraer el id; instala jq)"
  separador
fi

# ---------------------------------------------------------
# Central (backend_central)
# ---------------------------------------------------------
llamar_gateway "central: recibir_evento" \
  '{"type":"central","action":"recibir_evento","params":{"name":"Tormenta","description":"Tormenta de arena","pos_x":50,"pos_y":60}}'
EVENTO_ID=$(extraer_id)

llamar_gateway "central: read_all_events" \
  '{"type":"central","action":"read_all_events","params":{}}'

if [ -n "$EVENTO_ID" ]; then
  llamar_gateway "central: update_event (id=$EVENTO_ID)" \
    "{\"type\":\"central\",\"action\":\"update_event\",\"params\":{\"id\":\"$EVENTO_ID\",\"name\":\"Tormenta\",\"description\":\"Revisada\",\"pos_x\":50,\"pos_y\":60}}"

  llamar_gateway "central: delete_event (id=$EVENTO_ID)" \
    "{\"type\":\"central\",\"action\":\"delete_event\",\"params\":{\"id\":\"$EVENTO_ID\"}}"
else
  echo ">> central: update_event / delete_event omitidos (no se pudo extraer el id; instala jq)"
  separador
fi

echo "Listo. Revisa arriba los códigos http y los cuerpos de respuesta de cada acción."
