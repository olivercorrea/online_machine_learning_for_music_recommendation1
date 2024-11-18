#!/bin/bash

# Definición de colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Definir la variable dockerId y version
dockerId="rimaro"
version="v2"

echo -e "${CYAN}☄️🪁------------------------------------------------------------🪁☄️${NC}"

# Subir imágenes a Docker Hub
echo -e "${CYAN}☁️ Subiendo imágenes a Docker Hub...${NC}"

# Subir Productor
echo -e "${YELLOW}📦 Subiendo imagen de Productor...${NC}"
docker push ${dockerId}/tproducer:${version}

# Subir Consumer
echo -e "${YELLOW}📦 Subiendo imagen de Consumer...${NC}"
docker push ${dockerId}/tconsumer:${version}

# Subir C# Service
echo -e "${YELLOW}📦 Subiendo imagen de C# Service...${NC}"
docker push ${dockerId}/tcsharp:${version}

# Subir Frontend en React
echo -e "${YELLOW}📦 Subiendo imagen de Frontend...${NC}"
docker push ${dockerId}/treact:${version}

echo -e "${GREEN}🚀 Imágenes subidas a Docker Hub...${NC}"
