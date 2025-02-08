# mysql.sh

MYSQL_CONTAINER="mysql"
MYSQL_IMAGE="mysql:lts"
MYSQL_PORT=3307
MYSQL_VOLUME="$(pwd)/mysql-data"
MYSQL_VOLUME_PATH="/var/lib/mysql"
MYSQL_USER="alaspina"
MYSQL_PASSWORD="123"
MYSQL_ROOT_PASSWORD="123"

postgres_init() {
    ensure_volume "$MYSQL_VOLUME"

    echo -e "🚀 Iniciando contenedor de $MYSQL_CONTAINER..."

    printf "📝 " && MSYS_NO_PATHCONV=1 docker run --restart=always -dp $MYSQL_PORT:3306 \
        --name $MYSQL_CONTAINER \
        --network $NET_CONTAINERS \
        --env MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
        --volume "$MYSQL_VOLUME":"$MYSQL_VOLUME_PATH" \
        $MYSQL_IMAGE

    echo -e "\n"
}

postgres_info() {
    echo "🖥️  mysql está disponible en el puerto $MYSQL_PORT"
}

export CONTAINER="$MYSQL_CONTAINER"
