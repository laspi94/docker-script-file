# Configuración de laravel-app
PHP_CONTAINER="php-fpm-stock-pos"
PHP_IMAGE="php:8.2-fpm-alpine"
PHP_VOLUME="/c/laragon/www/stock-pos-laravel"
PHP_VOLUME_PATH="/var/www/html"
PHP_PORT="9002"

# Función para iniciar el contenedor de Laravel
laravelApp_init() {
    echo "🚀 Iniciando contenedor de PHP-FPM..."
    printf "📝 " && MSYS_NO_PATHCONV=1 docker run -d \
        --name $PHP_CONTAINER \
        -v "$PHP_VOLUME":"$PHP_VOLUME_PATH" \
        $PHP_IMAGE

    connect_container_to_network "$NET_CONTAINER" "$PHP_CONTAINER"

    echo -e "\n"
}

# Función para mostrar mensaje de Laravel
laravel_info() {
    echo "🖥️ php-fpm está disponible"
}

# Exportar la variable del contenedor
export CONTAINER="$PHP_CONTAINER"
