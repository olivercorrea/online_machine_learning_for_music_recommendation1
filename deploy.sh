#!/bin/bash

echo "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀"
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
echo "🚀 Kafka desplegado..."

# Desplegar Producer
cd OLearning/Producer
docker build -t producer .
remove_container_if_exists "producer-container"
docker run -d --network=kafka_confluent -it --name producer-container producer
sleep 30
echo "🚀 Productor desplegado..."
cd ..

# Desplegar Consumer
cd Consumer
docker build -t consumer .
remove_container_if_exists "consumer-container"
docker run -d --network=kafka_confluent -it --name consumer-container consumer
echo "🚀 Consumer desplegado..."
cd ../..

# Desplegar C# Service
cd MusicRecommendations
docker build -t csharp .
remove_container_if_exists "csharp-container"
docker run -d --network=kafka_confluent -it --name csharp-container -p 8080:8080 csharp
echo "🚀 C# Service desplegado..."
cd ..

# Obtener IP pública de la instancia EC2
#EC2_PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/)
PUBLIC_IP=$(curl -s ifconfig.me)
echo "IP pública: $PUBLIC_IP"

# Desplegar Frontend en React
cd music-recommendations-frontend
docker build -t react .
remove_container_if_exists "react-container"
docker run -d --network=kafka_confluent -it --name react-container -p 3000:3000 -e REACT_APP_API_BASE_URL=http://$PUBLIC_IP:8080/api react
echo "🚀 React desplegado..."

echo "IP pública: http://$PUBLIC_IP:3000/"
echo "🚀 Despliegue Terminado"
