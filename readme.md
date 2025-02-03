# Script de gestión de contenedores Docker

Este script permite gestionar contenedores de Docker de manera mas sencilla para el proyecto, permitiendo agregar y configurar diferentes contenedores de servicios según las necesidades del usuario.

### Requisitos

- **Docker**: Debes tener Docker instalado en tu máquina. Si no lo tienes, puedes instalarlo desde [aquí](https://docs.docker.com/desktop/setup/install/linux/).
- **Bash**: El script está diseñado para ejecutarse en un entorno que soporte Bash.

### Estructura de archivos

> ├── docker-config.sh
> 
> ├── docker-ctl.sh
> 
> ├── docker-script.sh
> 
> └── containers
> 
>    ├── postgres.sh
> 
>    └── pgadmin.sh


### Comandos de uso

> Iniciar los contenedores
```bash
./docker-ctl.sh start
```

> Detiene los contenedores
```bash
./docker-ctl.sh stop
```

> Reinicia los contenedores
```bash
./docker-ctl.sh restart
```

> Visualizar logs de algún contenedor en específico
```bash
./docker-ctl.sh logs {contenedor}
```

> Listar contendores cargados y su disponibilidad
```bash
./docker-ctl.sh list
```

> Ejecutar comandos dentro del contenedor
```bash
./docker-ctl.sh exec {contenedor}
```

###### Define el nombre del proyecto en `docker-config.sh`
PROJECT_NAME="example-project"

###### Ejemplo de un contenedor para postgres -> `postgres.sh`

```bash

POSTGRES_CONTAINER="postgres"
POSTGRES_IMAGE="postgres:16.6-alpine3.21"
POSTGRES_PORT=5433
POSTGRES_VOLUME="postgres-data"
POSTGRES_VOLUME_PATH="/var/lib/postgresql/data"
POSTGRES_PASSWORD="casealfa"

#postgres
postgres_init(){
    ensure_volume "$POSTGRES_VOLUME"

    echo -e "🚀 Iniciando contenedor de POSTGRES_CONTAINER..."

    printf  "📝 " && docker run -dp $POSTGRES_PORT:5432 \
    --name $POSTGRES_CONTAINER \
    --env POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    --volume "$POSTGRES_VOLUME":"$POSTGRES_VOLUME_PATH" \
    $POSTGRES_IMAGE
    echo -e "\n"
}

postgres_info(){
    echo "🖥️ postgres está disponible en el puerto $POSTGRES_PORT"
}

export CONTAINER="$POSTGRES_CONTAINER"

```

> **Observación:** En caso de asignar un directorio reflejo en el volumen de tu contenedor asegurate de comentar la función `ensure_volume` o eliminarla:

```bash
   # ensure_volume "$POSTGRES_VOLUME"
```

> Recuerda definir el nombre de tu contenedor como único para evitar conflictos en el lanzamiento del mismo

#### Recuerda que si estás montando multiples servicios de un mismo script en un mismo OS debes añadir un nombre unico para cada script en el nombre de tu contenedor ejemplo: postgres-{nombre-proyecto}

```bash
POSTGRES_CONTAINER=postgres-{nombre-proyecto}
```