#!/bin/bash

echo "🚀 Iniciando despliegue..."

# Clonar el repositorio si no existe
if [ ! -d "online_machine_learning_for_music_recommendation1" ]; then
    git clone https://github.com/olivercorrea/online_machine_learning_for_music_recommendation1.git
    cd online_machine_learning_for_music_recommendation1
else
    echo "📂 El repositorio ya existe, omitiendo clonación."
    cd online_machine_learning_for_music_recommendation1
    git pull origin v4
fi

# Cambiar a la rama especificada
git switch v4

# set up enviroment
chmod +x setup.sh
./setup.sh

# SWAP memory
chmod +x swap.sh
./swap.sh

# Portainer
chmod +x portainer.sh
./portainer.sh
sleep 15

# Hacer que el script de despliegue sea ejecutable
chmod +x deploy.sh

# Ejecutar el script de despliegue en una nueva sesión de shell para evitar reinicios
newgrp docker <<EOF
# Ejecutar el script de despliegue
./deploy.sh
EOF

echo "🎉🎉🎉🎉 Tu proyecto esta desplegado 🎉🎉🎉🎉"
