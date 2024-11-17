#!/bin/bash

# Definición de colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

echo -e "${CYAN☄️🪁------------------------------------------------------------🪁☄️NC}"
echo -e "${GREEN}🚀 Desplegando Portainer...${NC}"

# Ejecutar el contenedor de Portainer
echo -e "${YELLOW}📦 Iniciando el contenedor de Portainer...${NC}"
sudo docker run -d -p 9000:9000 --restart always --name portainer \
-v /var/run/docker.sock:/var/run/docker.sock \
portainer/portainer-ce

# Obtener la IP pública
PUBLIC_IP=$(curl -s ifconfig.me)
echo -e "${YELLOW}🌐 IP pública: http://$PUBLIC_IP:9000/${NC}"
echo -e "${GREEN}🚀 Portainer en ejecución...${NC}"
