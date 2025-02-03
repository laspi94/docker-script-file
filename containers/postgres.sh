POSTGRES_CONTAINER="postgres-stock-pos"
POSTGRES_IMAGE="postgres:16.6-alpine3.21"
POSTGRES_PORT=5433
POSTGRES_VOLUME="postgres-01"
POSTGRES_VOLUME_PATH="/var/lib/postgresql/data"
POSTGRES_PASSWORD="123"

#postgres
postgres_init() {
    ensure_volume "$POSTGRES_VOLUME"

    echo -e "🚀 Iniciando contenedor de $POSTGRES_CONTAINER..."

    printf "📝 " && MSYS_NO_PATHCONV=1 docker run -dp $POSTGRES_PORT:5432 \
        --name $POSTGRES_CONTAINER \
        --env POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
        --volume "$POSTGRES_VOLUME":"$POSTGRES_VOLUME_PATH" \
        $POSTGRES_IMAGE

    connect_container_to_network "$NET_CONTAINER" "$POSTGRES_CONTAINER"

    echo -e "\n"
}

postgres_info() {
    echo "🖥️ postgres está disponible en el puerto $POSTGRES_PORT"
}

export CONTAINER="$POSTGRES_CONTAINER"
