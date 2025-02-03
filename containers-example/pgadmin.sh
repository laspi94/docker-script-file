# pgadmin.sh

# Configuración de pgAdmin
PGADMIN_CONTAINER="pgadmin4"
PGADMIN_IMAGE="dpage/pgadmin4:8"
PGADMIN_PORT=8080
PGADMIN_VOLUME="pgadmin-01"
PGADMIN_VOLUME_PATH="/var/lib/pgadmin"
PGADMIN_DEFAULT_EMAIL="alaspina@gmail.com"
PGADMIN_DEFAULT_PASSWORD="123"

# Función para iniciar pgAdmin
pgAdmin_init() {
    ensure_volume "$PGADMIN_VOLUME"

    echo -e "🚀 Iniciando contenedor de $PGADMIN_CONTAINER..."
    
    printf "📝 " && MSYS_NO_PATHCONV=1 docker run -d \
        --name $PGADMIN_CONTAINER \
        --env PGADMIN_DEFAULT_EMAIL="$PGADMIN_DEFAULT_EMAIL" \
        --env PGADMIN_DEFAULT_PASSWORD="$PGADMIN_DEFAULT_PASSWORD" \
        -p $PGADMIN_PORT:80 \
        --volume "$PGADMIN_VOLUME":"$PGADMIN_VOLUME_PATH" \
        $PGADMIN_IMAGE
    echo -e "\n"
}

# Función para mostrar mensaje de pgAdmin
pgAdmin_info() {
    echo "🖥️ pgAdmin está disponible en http://localhost:$PGADMIN_PORT"
}

# Exportar la variable CONTAINERS
export CONTAINER="$PGADMIN_CONTAINER"
