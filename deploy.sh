#!/bin/bash

cd kafka
docker-compose up -d
cd ..
cd OLearning/Producer
docker build -t producer .
docker run -d --network=kafka_confluent -it --name producer-container producer
sleep 30
cd ..
cd Consumer
docker build -t consumer .
docker run -d --network=kafka_confluent -it --name consumer-container consumer
cd ..
cd ..
cd MusicRecommendations
docker build -t csharp .
docker run -d --network=kafka_confluent -it --name csharp-container -p 8080:8080 csharp
cd ..
cd music-recommendations-frontend
docker build -t react .
docker run -d --network=kafka_confluent -it --name react-container -p 3000:3000 react