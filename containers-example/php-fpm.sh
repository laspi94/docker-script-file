# php-fpm.sh

# Configuración de laravel-app
PHP_CONTAINER="php-fpm"
PHP_IMAGE="php:8.2-fpm-alpine3.21"
PHP_VOLUME="/c/laragon/www/stock-pos"
PHP_VOLUME_PATH="/var/www/html"
PHP_PORT="9000"

laravelApp_init() {
    echo "🚀 Iniciando contenedor de $PHP_CONTAINER..."

    printf "📝 " && MSYS_NO_PATHCONV=1 docker run --restart=always -d \
        --name $PHP_CONTAINER \
        --network $NET_CONTAINERS \
        -p "$PHP_PORT":9000 \
        -v "$PHP_VOLUME":"$PHP_VOLUME_PATH" \
        $PHP_IMAGE \
        sh -c "apk add --no-cache postgresql-dev \
        && docker-php-ext-install pdo_pgsql \
        && php-fpm"

    echo -e "\n"
}

laravel_info() {
    echo "🖥️  php-fpm está disponible"
}

# Exportar la variable del contenedor
export CONTAINER="$PHP_CONTAINER"
