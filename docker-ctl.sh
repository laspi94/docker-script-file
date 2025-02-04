#!/bin/bash

source ./docker-config.sh

###################################################################################
## Configuraciones del SCRIPT (No modificar nada, al menos que sepa lo que hace) ##
###################################################################################

# Función para iniciar los contenedores
start_containers() {
    containers_if_running

    #red de servicios (el script se encarga de iniciar una red con el nombre del proyecto)
    create_network

    # Ejecutar dinámicamente todas las funciones que terminan en _init
    for func in $(declare -F | awk '{print $3}'); do
        if [[ "$func" == *"_init" ]]; then
            $func # Ejecuta la función
        fi
    done

    echo "✅ Contenedores iniciados: "
    # Ejecutar dinámicamente todas las funciones que terminan en _info
    for func in $(declare -F | awk '{print $3}'); do
        if [[ "$func" == *"_info" ]]; then
            $func # Ejecuta la función
        fi
    done

    #mensajes de disponibilidad red
    network_message
}

# Variables global de la red
NET_CONTAINERS="${NETWORKING_NAME}"

CONTAINERS=() # Inicializa una lista vacía de contenedores

load_containers() {
    script_dir="./containers" # Cambia a la ruta de tu directorio

    pattern_init="_init"

    pattern_info="_info"

    # Verificar si el directorio existe
    if [ -d "$script_dir" ]; then
        for script in "$script_dir"/*; do
            if [ -f "$script" ]; then # Verificar que sea un archivo

                source "$script"

                if ! grep -q "^\s*\w*$pattern\s*()" "$script"; then
                    echo "❌ Se encontró función la función '$pattern_init' dentro del contenedor importado $(basename "$script")"
                    exit 1
                fi

                if ! grep -q "^\s*\w*$pattern_info\s*()" "$script"; then
                    echo "❌ Se encontró función la función '$pattern_info' dentro del contenedor importado $(basename "$script")"
                    exit 1
                fi

                # Concatenar el valor de CONTAINER al listado
                if [ -n "$CONTAINER" ]; then
                    CONTAINERS+=("$CONTAINER")
                fi
            fi
        done

        # Verificar si el arreglo está vacío
        if [ ${#CONTAINERS[@]} -eq 0 ]; then
            echo -e "⚠️ No se detectó ningun contenedor"
            exit 1
        fi
    else
        echo -e "⚠️ El directorio $script_dir no existe."
        exit 1
    fi
}

#red de contenedores
create_network() {
    echo "🚀 Iniciando red de contenedores..."
    printf "📝 " && docker network create $NET_CONTAINERS 2>/dev/null && echo -e "⚠️ Red de contenedores no existe. Creando 🌐 $NET_CONTAINERS" || echo -e "✅ La red ya existe, creación cancelada. "
    echo -e "🌐 $NET_CONTAINERS \n"
}

#red de contenedores
network_message() {
    echo -e "🌐 Red disponible: $NET_CONTAINERS. \n"
}

# Función para reiniciar los contenedores
restart_containers() {
    containers_if_exist

    echo "🚀 Reiniciando contenedores..."
    delete_containers
    start_containers
}

# Función para eliminar un contenedor
delete_container() {
    container_name=$1 # Nombre del contenedor a eliminar

    printf "⏳ Eliminando contenedor: "
    docker container rm -f $container_name 2>/dev/null && echo -e "\n✅ contenedor $container_name eliminado"
    echo -e "\n"
}

# Función para eliminar la red de contenedores
delete_network() {
    network_name=$1 # Nombre de la red a eliminar

    printf "⏳ Eliminando red de contenedores: "
    docker network rm -f $network_name 2>/dev/null && echo -e "\n✅ Red de contenedores $network_name eliminada"
    echo -e "\n"
}

# Función para detener un contenedor si está en ejecución
stop_container_if_running() {
    container_name=$1 # Nombre del contenedor que se pasa como argumento

    if [ "$(docker container inspect -f '{{.State.Running}}' $container_name)" == "true" ]; then
        printf "Deteniendo contenedor de -> "
        docker container stop $container_name 2>/dev/null && printf "\r✅ $container_name detenido." || exit_with_message "\r❌ $container_name no pudo ser detenido."
    else
        printf "\r❌ $container_name ya está detenido."
    fi
    echo -e "\n"
}

# Función para verificar estado de los contenedores
containers_if_running() {
    for container in "${CONTAINERS[@]}"; do
        # Verifica si el contenedor existe
        if docker ps -a --format '{{.Names}}' | grep -w "$container" >/dev/null; then
            # Verifica si el contenedor está en ejecución
            if [ "$(docker container inspect -f '{{.State.Running}}' $container)" == "true" ]; then
                exit_with_message "\n⚠️ Los contenedores ya se encuentran en ejecución."
            fi
        fi
    done
}

# Función para verificar si los contenedores existen
containers_if_exist() {
    local container_found=true # Inicializa una variable para verificar si se encuentra un contenedor

    for container in "${CONTAINERS[@]}"; do
        # Verifica si el contenedor existe
        if ! docker ps -a --format '{{.Names}}' | grep -w "$container" >/dev/null; then
            echo -e "\n⚠️ Los contenedores no se encuentran en ejecución."
            container_found=false # Cambia el valor si no se encuentra el contenedor
            break
        fi
    done

    # Si no se encontró ningún contenedor, pregunta si desea iniciar los contenedores
    if ! $container_found; then
        # Pregunta si desea iniciar los contenedores
        echo -e "\n¿Deseas iniciar los contenedores? (y/n): "
        read confirm
        echo -e "\n"
        if [[ "$confirm" == "y" || "$confirm" == "yes" || "$confirm" == "Y" || "$confirm" == "Yes" ]]; then
            start_containers
            exit 1
        else
            exit 1
        fi
    fi
}

# Función para verificar y crear el volumen si no existe
ensure_volume() {
    local volume_name=$1

    # Verifica si el volumen es un path (comienza con '/')
    if [[ "$volume_name" =~ ^/ ]]; then
        # Es un path, asegúrate de que el directorio exista
        if [[ -d "$volume_name" ]]; then
            echo "✅ El path '$volume_name' ya existe."
        else
            echo "⚠️ El path '$volume_name' no existe. Creando directorio..."
            mkdir -p "$volume_name" && echo "✅ Directorio '$volume_name' creado exitosamente"
        fi
    else
        # Es un volumen de Docker
        if docker volume ls --format '{{.Name}}' | grep -q "^${volume_name}$"; then
            echo "✅ Volumen Docker '$volume_name' ya existe"
        else
            echo "⚠️ El volumen Docker '$volume_name' no existe. Creando..."
            docker volume create --name "$volume_name" && echo "✅ Volumen Docker '$volume_name' creado exitosamente"
        fi
    fi
}

# Función para conectar un contenedor a la red
connect_container_to_network() {
    network_name=$1   # Nombre de la red
    container_name=$2 # Nombre del contenedor

    echo "⏳ Conectando contenedor $container_name a la red -> $network_name"
    docker network connect $network_name $container_name 2>/dev/null && echo -e "⚡ $container_name conectado" || exit_with_message "❌ $container_name no se pudo conectar a la red"
}

# Función para ver log de un contenedor
log_container() {
    docker container logs -f "$1"
}

# Función para detener los contenedores
stop_containers() {
    for container in "${CONTAINERS[@]}"; do
        stop_container_if_running "$container"
    done
}

# Función para eliminar los contenedores
delete_containers() {
    for container in "${CONTAINERS[@]}"; do
        delete_container "$container"
    done

    delete_network $NET_CONTAINERS
}

# Función para verificar si el contenedor está en el listado
is_container_defined() {
    local container_name=$1 # Nombre del contenedor a verificar

    # Compara si el contenedor está en el arreglo CONTAINERS
    if [[ " ${CONTAINERS[@]} " =~ " ${container_name} " ]]; then
        return 0 # Contenedor encontrado
    else
        return 1 # Contenedor no encontrado
    fi
}

# Verifica si el argumento está vacío
check_argument() {
    # Verifica si el argumento está vacío
    if [[ -z "$1" ]]; then
        exit_with_message "⚙  Contenedor '$1' no definido."
    fi
}

# Ejecución de comandos dentro del contenedor
execute_in_container() {
    docker exec -it $1 sh
}

# Función para mostrar el mensaje de error
exit_with_message() {
    echo -e "$1"
    exit 1
}

# Función para mostrar el mensaje de error
show_project_name() {
    echo -e "📂︎ $PROJECT_NAME"
    exit 1
}

# Función para mostrar el mensaje de error
show_network_name() {
    echo -e "🌐 $NET_CONTAINERS"
    exit 1
}

# Verifica el argumento pasado al script
case $1 in
start)
    load_containers

    start_containers
    ;;
stop)
    load_containers

    # Pregunta de confirmación
    echo -e "¿Estás seguro de que deseas detener los contenedores? (y/n):"
    read confirm
    if [[ "$confirm" == "y" || "$confirm" == "yes" || "$confirm" == "Y" || "$confirm" == "Yes" ]]; then
        delete_containers
    else
        echo -e "\n⚠️ Operación cancelada."
    fi
    ;;
restart)
    load_containers

    echo -e "¿Estás seguro de que deseas reiniciar los contenedores? (y/n):"
    read confirm
    if [[ "$confirm" == "y" || "$confirm" == "yes" || "$confirm" == "Y" || "$confirm" == "Yes" ]]; then
        restart_containers
    else
        exit_with_message "\n⚠️ Operación cancelada."
    fi
    ;;
logs)
    load_containers

    check_argument $2

    if is_container_defined "$2"; then
        # Verifica si el contenedor está en la lista
        if [[ " ${CONTAINERS[@]} " =~ " $2 " ]]; then
            log_container "$2"
        else
            exit_with_message "$(
                IFS='|'
                echo "⚙  Uso: $0 exec {${CONTAINERS[*]}}"
            )"
        fi
    else
        exit_with_message "⚙  Contenedor '$2' no definido."
    fi
    ;;
status)
    load_containers

    # Ver listado de los contenedores cargados y su disponibilidad
    for container in "${CONTAINERS[@]}"; do
        CONTAINER_ID=$(docker ps -qf "name=$container")

        if [[ -z "$CONTAINER_ID" ]]; then
            echo -e "📦 $container - ⚠️ No está en ejecución"
        else
            echo -e "📦 $container - 🟢 En ejecución"
        fi
    done
    ;;
list)
    load_containers

    # Ver listado de los contenedores cargados y su disponibilidad
    for container in "${CONTAINERS[@]}"; do
        CONTAINER_ID=$(docker ps -qf "name=$container")

        if [[ -z "$CONTAINER_ID" ]]; then
            echo -e "📦 $container - ⚠️ No está en ejecución"
        else
            echo -e "📦 $container - 🆔 $CONTAINER_ID"
        fi
    done
    ;;
exec)
    load_containers

    check_argument "$2"

    if is_container_defined "$2"; then
        # Verifica si el contenedor está en la lista
        if [[ " ${CONTAINERS[@]} " =~ " $2 " ]]; then
            execute_in_container "$2"
        else
            exit_with_message "$(
                IFS='|'
                echo "⚙  Uso: $0 exec {${CONTAINERS[*]}}"
            )"
        fi
    else
        exit_with_message "$(
            IFS='|'
            echo "⚙  Uso: $0 exec {${CONTAINERS[*]}}"
        )"
    fi
    ;;
project)
    show_project_name
    ;;
network)
    show_network_name
    ;;
help)
    echo "⛑  comandos disponibles: "
    echo -e "• \e[1;33mstart\e[0m      - Inicia los contenedores definidos"
    echo -e "• \e[1;33mstop\e[0m       - Elimina todos los contenedores definidos"
    echo -e "• \e[1;33mrestart\e[0m    - Reinicia todos los contenedores definidos"
    echo -e "• \e[1;33mlogs \$foo\e[0m  - Visualiza los logs de un contenedor específico"
    echo -e "• \e[1;33mstatus\e[0m     - Visualiza el estado de los contenedores"
    echo -e "• \e[1;33mlist\e[0m       - Lista los contenedores definidos con su ID"
    echo -e "• \e[1;33mexec \$foo\e[0m  - Ejecuta comandos dentro del contenedor"
    echo -e "• \e[1;33mproject\e[0m    - Visualiza el nombre del proyecto asignado"
    echo -e "• \e[1;33mnetwork\e[0m    - Visualiza el nombre de la RED asignada"
    ;;
*)
    exit_with_message "⚙  Uso: $0 {start|stop|restart|logs|status|list|exec|project|network|help}"
    ;;
esac
