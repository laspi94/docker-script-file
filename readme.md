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
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── postgres.sh
> 
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── pgadmin.sh

### Variables globales diponibles

> 

### Uso

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

### Crea el archivo de configuración llamado `docker-config.sh` con la siguiente estructura:

```bash
#define el nombre de tu proyecto
PROJECT_NAME="project-name"

#define el nombre de la red de contenedores
NETWORKING_NAME="network-name"

# no modificar
export PROJECT_NAME
export NETWORKING_NAME
```

### Ejemplo de un contenedor para postgres -> `postgres.sh`

```bash
POSTGRES_CONTAINER="postgres"
POSTGRES_IMAGE="postgres:16.6-alpine3.21"
POSTGRES_PORT=5433
POSTGRES_VOLUME="postgres-data"
POSTGRES_VOLUME_PATH="/var/lib/postgresql/data"
POSTGRES_PASSWORD="123456"

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
    echo "🖥️  postgres está disponible en el puerto $POSTGRES_PORT"
}

export CONTAINER="$POSTGRES_CONTAINER"

```
> Para la función de lanzamiento del contenedor la función debe finalizar con `_init`

> También es requerido que la función finzalice con `_info` en caso de querer visualizar nu mensaje de información cada vez que inicia el contenedor

> Exportar el nombre del contenedor de la siguiente manera `export CONTAINER="$POSTGRES_CONTAINER"` para que el script identifique tus conenedores cargados

## Test
Copia todo el contenido de la carpeta `containers-example` a `containers` y luego ejecuta:

```bash
./docker-ctl.sh start
```

```bash
./docker-ctl.sh start
```


## Observaciones
>  En caso de asignar un directorio reflejo en el volumen de tu contenedor asegurate de comentar la función `ensure_volume` o eliminarla:
> `ensure_volume` se encarga de verificar la existencia del volumen y crearlo en caso de que no exista

```bash
   # ensure_volume "$POSTGRES_VOLUME"
```

> Recuerda definir el nombre de tu contenedor como único para evitar conflictos en el lanzamiento del mismo

```bash
POSTGRES_CONTAINER=postgres-{nombre-proyecto}
```

## Autor

Este script fue desarrollado por:

- **Nombre del Autor**: [Alan Laspina](https://github.com/laspi94)
- **Correo**: [alanjoselaspina@gmail.com](mailto:alanjoselaspina@gmail.com)
- **GitHub**: [laspi94](https://github.com/laspi94)

## License

![Licencia MIT](https://img.shields.io/badge/License-MIT-green.svg)