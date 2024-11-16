#!/bin/bash

echo "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀"
echo "🚀 Iniciando el Set Up"

sudo apt update
sudo apt install nala -y
sudo nala install docker.io docker-compose -y

# Descargar imagenes
sudo docker pull confluentinc/cp-zookeeper:7.4.0
sudo docker pull confluentinc/cp-server:7.4.0
sudo docker pull confluentinc/cp-schema-registry:7.4.0
sudo docker pull confluentinc/cp-enterprise-control-center:7.4.0
sudo docker pull mcr.microsoft.com/dotnet/sdk:8.0
sudo docker pull python:3.9
sudo docker pull node:20
sudo docker pull portainer/portainer-ce

sudo usermod -aG docker $(whoami)

# Abrir una nueva sesión de shell para aplicar el cambio de grupo
#newgrp docker
sg docker << 'EOF'
docker -v
docker ps
EOF

echo "🚀 Set UP terminado ..."
