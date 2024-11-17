#!/bin/bash

# Definición de colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

echo -e "${CYAN☄️🪁------------------------------------------------------------🪁☄️NC}"
echo -e "${GREEN}🚀 Iniciando despliegue...${NC}"
🦸
# Verificar si docker-compose está disponible
if command -v docker-compose &>/dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

# Función para eliminar contenedor si existe
remove_container_if_exists() {
    container_name=$1
    if [ $(docker ps -a -q -f name=${container_name}) ]; then
        echo -e "${YELLOW}🗑️ Eliminando contenedor existente: ${container_name}...${NC}"
        docker rm -f ${container_name}
    fi
}

# Función para crear red si no existe
create_network_if_not_exists() {
    network_name=$1
    if ! docker network ls | grep -q ${network_name}; then
        echo -e "${YELLOW}🌐 Creando red: ${network_name}...${NC}"
        docker network create ${network_name}
    fi
}

# Crear red kafka_confluent si no existe
create_network_if_not_exists "kafka_confluent"

# Obtener IP pública de la instancia EC2
PUBLIC_IP=$(curl -s ifconfig.me)
echo -e "${YELLOW}🌍 IP pública: $PUBLIC_IP${NC}"

# Subir Kafka
cd kafka
echo -e "${YELLOW}📦 Subiendo Kafka...${NC}"
$DOCKER_COMPOSE up -d
cd ..
echo -e "${YELLOW}🌍 IP pública: http://$PUBLIC_IP:9021/${NC}"
echo -e "${GREEN}🚀 Kafka desplegado...${NC}"

# Desplegar Producer
cd OLearning/Producer
echo -e "${YELLOW}📦 Desplegando Productor...${NC}"
docker build -t producer .
remove_container_if_exists "producer-container"
docker run -d --network=kafka_confluent -it --name producer-container producer
echo -e "${GREEN}🚀 Productor desplegado...${NC}"
cd ..

# Desplegar Consumer
cd Consumer
echo -e "${YELLOW}📦 Desplegando Consumer...${NC}"
docker build -t consumer .
remove_container_if_exists "consumer-container"
docker run -d --network=kafka_confluent -it --name consumer-container consumer
echo -e "${GREEN}🚀 Consumer desplegado...${NC}"
cd ../..

# Desplegar C# Service
cd MusicRecommendations
echo -e "${YELLOW}📦 Desplegando C# Service...${NC}"
docker build -t csharp .
remove_container_if_exists "csharp-container"
docker run -d --network=kafka_confluent -it --name csharp-container -p 8080:8080 csharp
echo -e "${GREEN}🚀 C# Service desplegado...${NC}"
cd ..

# Desplegar Frontend en React
cd music-recommendations-frontend
echo -e "${YELLOW}📦 Desplegando Frontend en React...${NC}"
docker build -t react .
remove_container_if_exists "react-container"
docker run -d --network=kafka_confluent -it --name react-container -p 3000:3000 react
echo -e "${YELLOW}🌍 IP pública: http://$PUBLIC_IP:3000/${NC}"
echo -e "${GREEN}🚀 React desplegado...${NC}"

echo -e "${GREEN}🚀 Despliegue Terminado${NC}"
