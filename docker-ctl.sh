#!/bin/bash

source ./docker-config.sh

###################################################################################
## Configuraciones del SCRIPT (No modificar nada, al menos que sepa lo que hace) ##
###################################################################################

# Función para iniciar los contenedores
start_containers() {
    containers_if_running

    #red de servicios (el script se encarga de iniciar una red con el nombre del proyecto)
    network

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

    #conectar contenedores a la red
    echo "⏳ Conectando contenedores a la red..."

    # Cambiar el delimitador a la coma
    # for container in "${CONTAINERS[@]}"; do
    #     connect_container_to_network "$NET_CONTAINER" "$container"
    # done
}

# script source
source ./docker-script.sh
