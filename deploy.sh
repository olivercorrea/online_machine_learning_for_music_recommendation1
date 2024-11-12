#!/bin/bash

echo "🚀 Iniciando despliegue..."

# Función para eliminar contenedor si existe
remove_container_if_exists() {
    container_name=$1
    if [ $(docker ps -a -q -f name=${container_name}) ]; then
        docker rm -f ${container_name}
    fi
}

# Subir Kafka
cd kafka
docker-compose up -d
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

# Desplegar Frontend en React
cd music-recommendations-frontend
docker build -t react .
remove_container_if_exists "react-container"
docker run -d --network=kafka_confluent -it --name react-container -p 3000:3000 react

echo "🚀 Despliegue Terminado"
