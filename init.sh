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

echo -e "${CYAN}🚀 Iniciando despliegue...${NC}"

# Clonar el repositorio si no existe
if [ ! -d "online_machine_learning_for_music_recommendation1" ]; then
    git clone https://github.com/olivercorrea/online_machine_learning_for_music_recommendation1.git
    cd online_machine_learning_for_music_recommendation1
else
    echo -e "${YELLOW}📂 El repositorio ya existe, omitiendo clonación.${NC}"
    cd online_machine_learning_for_music_recommendation1
    git pull origin v5
fi

# Cambiar a la rama especificada
git switch v5

# Set up environment
chmod +x setup.sh
./setup.sh

# SWAP memory
chmod +x swap.sh
./swap.sh

# Portainer
chmod +x portainer.sh
./portainer.sh
sleep 15

# Hacer que el script de despliegue sea ejecutable
chmod +x deploy.sh

# Ejecutar el script de despliegue en una nueva sesión de shell para evitar reinicios
newgrp docker <<EOF
# Ejecutar el script de despliegue
./deploy.sh
EOF

# Capturar el tiempo de finalización
end_time=$(date +%s)

# Calcular el tiempo total en segundos
total_time=$(( end_time - start_time ))

# Imprimir el tiempo total
echo -e "${GREEN}⏰ Tiempo total de ejecución: ${total_time} segundos.${NC}"

echo -e "${GREEN}🎉🎉🎉🎉 Tu proyecto está desplegado 🎉🎉🎉🎉${NC}"
