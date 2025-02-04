# nginx.sh

# Configuración de Nginx
NGINX_CONTAINER="nginx"
NGINX_IMAGE="nginx:stable-alpine"
NGINX_PORT=8081
NGINX_VOLUME="/c/laragon/www/stock-pos"                 # Ruta al proyecto Laravel
NGINX_CONFIG="$(pwd)/containers/configs/default.conf"   # Ruta al archivo de configuración de Nginx
NGINX_VOLUME_PATH="/var/www/html"

# Función para iniciar el contenedor de Nginx
nginx_init() {
    ensure_volume "$NGINX_VOLUME"

    echo "🚀 Iniciando contenedor de $NGINX_CONTAINER..."

    printf "📝 " && MSYS_NO_PATHCONV=1 docker run -d \
        --name $NGINX_CONTAINER \
        --network $NET_CONTAINERS \
        -p $NGINX_PORT:80 \
        -v "$NGINX_VOLUME":"$NGINX_VOLUME_PATH" \
        -v "$NGINX_CONFIG":"/etc/nginx/conf.d/default.conf" \
        $NGINX_IMAGE 

    echo -e "\n"
}

nginx_info() {
    echo "🖥️ Nginx está disponible en http://localhost:$NGINX_PORT"
}

# Exportar la variable del contenedor
export CONTAINER="$NGINX_CONTAINER"
