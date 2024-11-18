#!/bin/bash

# Definición de colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Definir la variable dockerId y version
dockerId="rimaro"
version="v1"

echo -e "${CYAN}☄️🪁------------------------------------------------------------🪁☄️${NC}"
echo -e "${GREEN}🚀 Building...${NC}"

# Construir Producer
cd OLearning/Producer
echo -e "${YELLOW}📦 Construyendo imagen de Productor...${NC}"
docker build -t ${dockerId}/tproducer:${version} .
echo -e "${GREEN}🚀 Imagen de Productor construido...${NC}"
cd ..

# Desplegar Consumer
cd Consumer
echo -e "${YELLOW}📦 Construyendo imagen de Consumer...${NC}"
docker build -t ${dockerId}/tconsumer:${version} .
echo -e "${GREEN}🚀 Imagen de Consumer construido...${NC}"
cd ../..

# Desplegar C# Service
cd MusicRecommendations
echo -e "${YELLOW}📦 Construyendo imagen de C# Service...${NC}"
docker build -t ${dockerId}/tcsharp:${version} .
echo -e "${GREEN}🚀 Imagen de C# Service construido...${NC}"
cd ..

# Desplegar Frontend en React
cd music-recommendations-frontend
echo -e "${YELLOW}📦 Construyendo imagen de Frontend...${NC}"
docker build -t ${dockerId}/treact:${version} .
echo -e "${GREEN}🚀 Imagen de React construido...${NC}"

echo -e "${GREEN}🚀 Imagenes construidas ...${NC}"
