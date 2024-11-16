#!/bin/bash

echo "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀"
echo "🚀 SWAP memory"

# Crear un archivo de swap de 1 GB
sudo fallocate -l 1G /swapfile

# Cambiar los permisos para que solo root pueda leer y escribir
sudo chmod 600 /swapfile

# Configurar el archivo como swap
sudo mkswap /swapfile

# Activar el swap
sudo swapon /swapfile

# Verificar que el swap esté activo
sudo swapon --show

echo "🚀 SWAP Finished"
