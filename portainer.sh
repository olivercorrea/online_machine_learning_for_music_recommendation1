#!/bin/bash

echo "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀"
echo "🚀 Deploying Portainer"

# Crear un archivo de swap de 1 GB
sudo docker run -d -p 9000:9000 --restart always --name portainer \
-v /var/run/docker.sock:/var/run/docker.sock \
portainer/portainer-ce

PUBLIC_IP=$(curl -s ifconfig.me)
echo "IP pública: http://$PUBLIC_IP:9000/"
echo "🚀 Portainer running ..."
