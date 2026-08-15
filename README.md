# Proyecto Supervisor de Rovers
---

## Primera ejecución

```
docker compose up db --build
docker exec -it backend_central mix ecto.migrate
```

- Ejecutar contenedores
```
docker compose up --build

```

---
## Unit Test del backend
- Ejecutar test
```
docker compose run --rm test
```
