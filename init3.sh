#!/bin/bash

# Definición de colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Capturar el tiempo de inicio
start_time=$(date +%s)

echo -e "${CYAN}🚀 Iniciando ...${NC}"

# Portainer
curl -O https://raw.githubusercontent.com/olivercorrea/online_machine_learning_for_music_recommendation1/v7/portainer.sh
chmod +x portainer.sh
./portainer.sh

# Hacer que el script de despliegue sea ejecutable
curl -O https://raw.githubusercontent.com/olivercorrea/online_machine_learning_for_music_recommendation1/v7/deploy2.sh
chmod +x deploy2.sh

# Ejecutar el script de despliegue en una nueva sesión de shell para evitar reinicios
newgrp docker <<EOF
# Ejecutar el script de despliegue
./deploy2.sh
EOF

# Capturar el tiempo de finalización
end_time=$(date +%s)

# Calcular el tiempo total en segundos
total_time=$(( end_time - start_time ))

# Imprimir el tiempo total
echo -e "${GREEN}⏰ Tiempo total de ejecución: ${total_time} segundos.${NC}"

echo -e "${GREEN}🎉🎉🎉🎉 Tu proyecto está desplegado 🎉🎉🎉🎉${NC}"
