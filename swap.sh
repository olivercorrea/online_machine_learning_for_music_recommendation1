#!/bin/bash

# Definición de colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

echo -e "${CYAN☄️🪁------------------------------------------------------------🪁☄️NC}"
echo -e "${GREEN}🚀 Iniciando configuración de SWAP memory...${NC}"

# Crear un archivo de swap de 1 GB
echo -e "${YELLOW}📦 Creando un archivo de swap de 1 GB...${NC}"
sudo fallocate -l 1G /swapfile

# Cambiar los permisos para que solo root pueda leer y escribir
echo -e "${YELLOW}🔒 Cambiando permisos del archivo de swap...${NC}"
sudo chmod 600 /swapfile

# Configurar el archivo como swap
echo -e "${YELLOW}⚙️ Configurando el archivo como swap...${NC}"
sudo mkswap /swapfile

# Activar el swap
echo -e "${YELLOW}🚀 Activando el swap...${NC}"
sudo swapon /swapfile

# Verificar que el swap esté activo
echo -e "${YELLOW}🔍 Verificando que el swap esté activo...${NC}"
sudo swapon --show

echo -e "${GREEN}🚀 SWAP Finished...${NC}"
