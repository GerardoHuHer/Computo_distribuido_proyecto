#!/bin/sh
set -e

echo "Creando base de datos"
mix ecto.create

echo "Corriendo migraciones"
mix ecto.migrate

echo "Levantando Phoenix"
exec mix phx.server
