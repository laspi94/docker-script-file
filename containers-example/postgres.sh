# postgres.sh

POSTGRES_CONTAINER="postgres"
POSTGRES_IMAGE="postgres:16.6-alpine3.21"
POSTGRES_PORT=5433
POSTGRES_VOLUME="$(pwd)/postgres-data"
POSTGRES_VOLUME_PATH="/var/lib/postgresql/data"
POSTGRES_PASSWORD="123"

postgres_init() {
    ensure_volume "$POSTGRES_VOLUME"

    echo -e "🚀 Iniciando contenedor de $POSTGRES_CONTAINER..."

    printf "📝 " && MSYS_NO_PATHCONV=1 docker run --restart=always -dp $POSTGRES_PORT:5432 \
        --name $POSTGRES_CONTAINER \
        --network $NET_CONTAINERS \
        --env POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
        --volume "$POSTGRES_VOLUME":"$POSTGRES_VOLUME_PATH" \
        $POSTGRES_IMAGE

    echo -e "\n"
}

postgres_info() {
    echo "🖥️  postgres está disponible en el puerto $POSTGRES_PORT"
}

export CONTAINER="$POSTGRES_CONTAINER"
