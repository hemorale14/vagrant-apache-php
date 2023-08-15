#!/bin/bash
# echo "Actualizar paquetes"
# sudo apt-get update > /dev/null

echo "y" | sudo ufw enable
echo "Abrir puertos necesarios"
sudo ufw allow ssh/tcp
sudo ufw allow 27017