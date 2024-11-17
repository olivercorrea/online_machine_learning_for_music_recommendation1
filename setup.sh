#!/bin/bash

# Definición de colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

echo -e "${CYAN☄️🪁------------------------------------------------------------🪁☄️NC}"
echo -e "${GREEN}🚀 Iniciando el Set Up...${NC}"

# Actualizar paquetes
echo -e "${YELLOW}🔄 Actualizando paquetes...${NC}"
sudo apt update

# Instalar Nala y Docker
echo -e "${YELLOW}📦 Instalando Nala y Docker...${NC}"
sudo apt install nala -y
sudo nala install docker.io docker-compose -y

# Descargar imágenes
echo -e "${YELLOW}⬇️ Descargando imágenes de Docker...${NC}"
sudo docker pull confluentinc/cp-zookeeper:7.4.0
sudo docker pull confluentinc/cp-server:7.4.0
sudo docker pull confluentinc/cp-schema-registry:7.4.0
sudo docker pull confluentinc/cp-enterprise-control-center:7.4.0
sudo docker pull mcr.microsoft.com/dotnet/sdk:8.0
sudo docker pull python:3.9
sudo docker pull node:20
sudo docker pull portainer/portainer-ce

# Agregar usuario al grupo de Docker
echo -e "${YELLOW}👤 Agregando usuario al grupo de Docker...${NC}"
sudo usermod -aG docker $(whoami)

# Abrir una nueva sesión de shell para aplicar el cambio de grupo
echo -e "${YELLOW}🔄 Aplicando cambios de grupo...${NC}"
sg docker << 'EOF'
docker -v
docker ps
EOF

echo -e "${GREEN}🚀 Set UP terminado...${NC}"
