# phpmyadmin.sh

PHPMYADMIN_CONTAINER="phpmyadmin"
PHPMYADMIN_IMAGE="phpmyadmin/phpmyadmin:latest"
PHPMYADMIN_PORT=8080
PHPMYADMIN_VOLUME="$(pwd)/phpmyadmin-data"
PHPMYADMIN_VOLUME_PATH="/var/lib/phpmyadmin"

pgAdmin_init() {
    ensure_volume "$PHPMYADMIN_VOLUME"

    echo -e "🚀 Iniciando contenedor de $PHPMYADMIN_CONTAINER..."
    
    printf "📝 " && MSYS_NO_PATHCONV=1 docker run --restart=always -d \
        --name $PHPMYADMIN_CONTAINER \
        --network $NET_CONTAINERS \
        -p $PHPMYADMIN_PORT:80 \
        --env PMA_HOST="mysql" \
        --env PMA_PORT="3306" \
        --volume "$PHPMYADMIN_VOLUME":"$PHPMYADMIN_VOLUME_PATH" \
        $PHPMYADMIN_IMAGE
    
    echo -e "\n"
}

pgAdmin_info() {
    echo "🖥️  pgAdmin está disponible en http://localhost:$PHPMYADMIN_PORT"
}

# Exportar la variable CONTAINERS
export CONTAINER="$PHPMYADMIN_CONTAINER"
