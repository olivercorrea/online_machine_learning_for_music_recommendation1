#!/bin/bash

echo "🚀 Iniciando despliegue..."

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
        docker rm -f ${container_name}
    fi
}

# Función para crear red si no existe
create_network_if_not_exists() {
    network_name=$1
    if ! docker network ls | grep -q ${network_name}; then
        docker network create ${network_name}
    fi
}

# Crear red kafka_confluent si no existe
create_network_if_not_exists "kafka_confluent"

# Subir Kafka
cd kafka
$DOCKER_COMPOSE up -d
cd ..

# Desplegar Producer
cd OLearning/Producer
docker build -t producer .
remove_container_if_exists "producer-container"
docker run -d --network=kafka_confluent -it --name producer-container producer
sleep 30
cd ..

# Desplegar Consumer
cd Consumer
docker build -t consumer .
remove_container_if_exists "consumer-container"
docker run -d --network=kafka_confluent -it --name consumer-container consumer
cd ..

# Desplegar C# Service
cd MusicRecommendations
docker build -t csharp .
remove_container_if_exists "csharp-container"
docker run -d --network=kafka_confluent -it --name csharp-container -p 8080:8080 csharp
cd ..

# Obtener la IP pública de la instancia EC2
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Desplegar Frontend en React con la URL base del API del backend
cd music-recommendations-frontend
docker build --build-arg REACT_APP_API_BASE_URL="http://$PUBLIC_IP:8080/api" -t react .
remove_container_if_exists "react-container"
docker run -d --network=kafka_confluent -it --name react-container -p 3000:3000 react

echo "🚀 Despliegue Terminado"
