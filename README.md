# Proyecto Supervisor de Rovers
---

## Descripción del proyecto

Proyecto para la materia Cómputo Distribuido. Este proyecto busca emular el funcionamiento de una central de control de rovers espaciales.
Para ello consta de los siguientes sistemas:
- Rover: Sistema que permite gestionar (crear, consultar, actualizar y eliminar rovers).
- Inventario: Sistema para simular el inventario que se tiene en la base.
- Central: Backend que recibe la información "generada" por los rovers

## Arquitectura
La arquitectura del proyecto parte de un MVC (Model-View-Controller) en el cuál el controlador (Backend) se dividio en tres distintos (los antes mecionados), este se conecta actualmente por medio de EDP (Erlang Distributed Protocol) usando el módulo Node y GenServer para comunicación entre los procesos.
Además de los Backends, se tiene un Middleware que funge como proxy para enviar la petición a cada uno de los backends y como Load Balancer para distribuir las 'n' peticiones entre los 'm' nodos que tenga de cada Backend.

## Requerimientos
- Docker instalado en computadora que se va a ejecutar.
- 16 GB de RAM


## Primera ejecución
```
  make setup
```

## Consultar opciones del Makefile
```
  make help
```
