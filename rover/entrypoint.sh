#!/bin/sh
set -e

echo "Creando base de datos"
mix ecto.create

echo "Corriendo migraciones"
mix ecto.migrate

NODE_IP=$(hostname -i)
exec elixir --name backend_rover@${NODE_IP} --cookie ${RELEASE_COOKIE} -S mix phx.server
