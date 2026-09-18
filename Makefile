DC = docker compose
MIDDLEWARE = middleware
ELIXIR_SERVICES = backend_central backend_vehiculo1 backend_inventario1
REACT_SERVICE = frontend
DB = db_central db_vehiculo db_inventario


.PHONY: help build build-app up down logs logs-app scale restart-app db-migrate test setup

help:
	@echo "=========================="
	@echo "ORQUESTADOR MICROSERVICIOS"
	@echo "=========================="
	@echo "Entorno general:"
	@echo " - make up                               - Levanta todos los contenedores en modo detach"
	@echo " - make down                             - Detiene todos los servicios"
	@echo " - make build                            - Reconstruye todas las imágenes"
	@echo " - make build-app APP=<nombre_app>       - Reconstruye todas las imágenes"
	@echo " - make logs                             - Muestra los logs de todas las aplicaciones"
	@echo " - make scale INS=<cantidad>             - Levanta <cantidad> de contenedores por servicio de elixir"
	@echo ""
	@echo "Tareas propias de Elixir"
	@echo " - make db-migrate                       - Ejecuta las migraciones de los servicios"
	@echo " - make test                             - Corre test de los servicios de Elixir"
	@echo ""
	@echo "Herramientas de desarrollo"
	@echo " - make logs-app APP=<nombre_app>        - Logs de un servicio en específico"
	@echo " - make restart-app APP=<nombre_app>     - Restart de un servicio en específico"

build:
	$(DC) build

build-app:
	@if [ -z "$(APP)" ]; then echo "Uso: make build-app APP=<nombre_servicio>"; exit 1; fi
	$(DC) build $(APP)

up:
	$(DC) up -d

down:
	$(DC) down

logs:
	$(DC) logs -f

logs-app:
	@if [ -z "$(APP)" ]; then echo "Uso: make logs-app APP=<nombre_servicio>"; exit 1; fi
	$(DC) logs -f $(APP)

scale:
	@if [ -z "$(INS)" ]; then echo "Uso: make scale INS=<cantidad instancias>"; exit 1; fi
	$(DC) up -d $(MIDDLEWARE)
	$(DC) up -d $(DB)
	$(DC) up -d $(REACT_SERVICE)
	@for service in $(ELIXIR_SERVICES); do \
		$(DC) up -d  --scale $$service=$(INS) $$service || exit 1; \
	done

restart-app:
	@if [ -z "$(APP)" ]; then echo "Uso: make restart-app APP=<nombre_servicio>"; exit 1; fi
	$(DC) restart $(APP)

db-migrate:
	@for service in $(ELIXIR_SERVICES); do \
		echo "Ejecutando migraciones en $$service" \
		$(DC) exec $$service mix ecto.migrate || exit 1; \
	done

test:
	@for service in $(ELIXIR_SERVICES); do \
		echo "Ejecutando test en $$service"
		$(DC) exec $$service mix test || exit 1; \
	done

setup: build up db-migrate
	@echo "Entorno configurado"

