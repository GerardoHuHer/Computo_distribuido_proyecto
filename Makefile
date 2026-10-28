# Comando de ejecución
DC = docker compose
# Servicios 
MIDDLEWARE = middleware
ELIXIR_SERVICES = backend_central backend_vehiculo1 backend_inventario1
REACT_SERVICE = frontend
DB = db_central db_vehiculo db_inventario
TEST_SERVICES = test_central test_vehiculo1 test_inventario1

JENKINS = jenkins


# Directiva para crear un target y evitar una tarea.
.PHONY: help build build-app up down logs logs-app scale restart-app db-migrate test setup jenkins rm-volumes vagrant

# Target help para mostrar funcionalidades
help:
	@echo "===================================================="
	@echo "            ORQUESTADOR MICROSERVICIOS"
	@echo "===================================================="
	@echo "Entorno general:"
	@echo " - make up                               - Levanta todos los contenedores en modo detach"
	@echo " - make down                             - Detiene todos los servicios"
	@echo " - make build                            - Reconstruye todas las imágenes"
	@echo " - make build-app APP=<nombre_app>       - Reconstruye la imagen de un servicio"
	@echo " - make logs                             - Muestra los logs de todas las aplicaciones"
	@echo " - make scale INS=<cantidad>             - Levanta <cantidad> de contenedores por servicio de elixir"
	@echo " - make rm-volumes                       - Borra los volumes del proyecto (excepto jenkins)"
	@echo ""
	@echo "Tareas propias de Elixir"
	@echo " - make db-migrate                       - Ejecuta las migraciones de los servicios"
	@echo " - make test                             - Corre test de los servicios de Elixir"
	@echo ""
	@echo "Herramientas de desarrollo"
	@echo " - make logs-app APP=<nombre_app>        - Logs de un servicio en específico"
	@echo " - make restart-app APP=<nombre_app>     - Restart de un servicio en específico"
	@echo ""
	@echo "CI/CD"
	@echo " - make jenkins                          - Levanta UI de Jenkins"
	@echo " - make vagrant                          - Levanta VM con Vagrant"


# Target para hacer build a todos los contenedores
build:
	$(DC) build

# Target para hacer build a build a un contenedor particular
build-app:
	@if [ -z "$(APP)" ]; then echo "Uso: make build-app APP=<nombre_servicio>"; exit 1; fi
	$(DC) build $(APP)

# Target para levantar los contenedores en modo detach
up:
	$(DC) up -d

# Target para apagar los contenedores
down:
	$(DC) down

# Logs de todos los contenedores activos en tiempo real
logs:
	$(DC) logs -f

# Logs de un contenedor en específico en tiempo real
logs-app:
	@if [ -z "$(APP)" ]; then echo "Uso: make logs-app APP=<nombre_servicio>"; exit 1; fi
	$(DC) logs -f $(APP)

# Target para especificar la cantidad de instancias (contenedores activos) por cada backend
scale:
	@if [ -z "$(INS)" ]; then echo "Uso: make scale INS=<cantidad instancias>"; exit 1; fi
	$(DC) up -d $(MIDDLEWARE)
	$(DC) up -d $(DB)
	$(DC) up -d $(REACT_SERVICE)
	@for service in $(ELIXIR_SERVICES); do \
		$(DC) up -d  --scale $$service=$(INS) $$service || exit 1; \
	done

# Target para reiniciar un contenedor
restart-app:
	@if [ -z "$(APP)" ]; then echo "Uso: make restart-app APP=<nombre_servicio>"; exit 1; fi
	$(DC) restart $(APP)

# target para hacer las migraciones de la base de datos
db-migrate:
	@for service in $(ELIXIR_SERVICES); do \
		echo "Ejecutando migraciones en $$service"; \
		$(DC) exec $$service mix ecto.migrate || exit 1; \
	done

# Target para los test de phoenix
test:
	@for service in $(TEST_SERVICES); do \
		echo "Ejecutando test en $$service"; \
		$(DC) --profile test run --rm $$service || exit 1; \
	done

# Target para el setup inicial
setup: build up db-migrate
	@echo "Entorno configurado"


jenkins:
	@echo "Levantando servidor de Jenkins"
	$(DC) up $(JENKINS)

rm-volumes:
	@echo "Eliminando volumes"
	docker volume rm $$(docker volume ls -q | grep "crud_project" | grep -v "crud_project_jenkins_home")

vagrant:
	@echo "Levantando VM"
	vagrant up --provider=libvirt --no-parallel
