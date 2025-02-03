# Configuración de Nginx
NGINX_CONTAINER="nginx-stock-pos"
NGINX_IMAGE="nginx:stable-alpine"
NGINX_PORT=8081
NGINX_VOLUME="/c/laragon/www/stock-pos-laravel"       # Ruta al proyecto Laravel
NGINX_CONFIG="$(pwd)/containers/configs/default.conf" # Ruta al archivo de configuración de Nginx
NGINX_VOLUME_PATH="/var/www/html"

# Función para iniciar el contenedor de Nginx
nginx_init() {
    # Iniciar el contenedor de Nginx
    echo "🚀 Iniciando contenedor de Nginx..."

    printf "📝 " && MSYS_NO_PATHCONV=1 docker run -d \
        --name $NGINX_CONTAINER \
        -p $NGINX_PORT:80 \
        -v "$NGINX_VOLUME":"$NGINX_VOLUME_PATH" \
        -v "$NGINX_CONFIG":"/etc/nginx/conf.d/default.conf" \
        $NGINX_IMAGE

    connect_container_to_network "$NET_CONTAINER" "$NGINX_CONTAINER"

    echo -e "\n"
}

# --volume "$NGINX_CONFIG":"/etc/nginx/nginx.conf:ro" \
# Función para mostrar mensaje de Nginx
nginx_info() {
    echo "🖥️ Nginx está disponible en http://localhost:$NGINX_PORT"
}

# Exportar la variable del contenedor
export CONTAINER="$NGINX_CONTAINER"
