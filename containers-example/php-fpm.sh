# Configuración de laravel-app
PHP_CONTAINER="php-fpm"
PHP_IMAGE="php:8.2-fpm-alpine3.21"
PHP_VOLUME="/c/laragon/www/stock-pos"
PHP_VOLUME_PATH="/var/www/html"
PHP_PORT="9000"

# Función para iniciar el contenedor de Laravel
laravelApp_init() {
    echo "🚀 Iniciando contenedor de PHP-FPM..."
    printf "📝 " && MSYS_NO_PATHCONV=1 docker run -d \
        --name $PHP_CONTAINER \
        --network $NET_CONTAINER \
        -p "$PHP_PORT":9000 \
        -v "$PHP_VOLUME":"$PHP_VOLUME_PATH" \
        $PHP_IMAGE 

    echo -e "\n"
}

# Función para mostrar mensaje de Laravel
laravel_info() {
    echo "🖥️ php-fpm está disponible"
}

# Exportar la variable del contenedor
export CONTAINER="$PHP_CONTAINER"
