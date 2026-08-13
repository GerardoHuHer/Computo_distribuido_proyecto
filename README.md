# Proyecto Supervisor de Rovers
---

## Unit Test del backend
1. Ejecutar contenedores
'''
docker compose up db backend
'''
2. Ejecutar test
'''
docker compose exec -e MIX_ENV=test -e DB_HOST=db backend mix test
'''
