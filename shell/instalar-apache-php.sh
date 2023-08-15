#!/bin/bash

echo "Inicia aprovicionamiento de Apache - PHP"

echo "Actualizar paquetes"
sudo apt-get update > /dev/null

echo "Establecer nombre de la maquina"
sudo hostnamectl set-hostname apachephphost.1002f.local

echo "Instalar apache"
echo "y" | sudo apt install apache2

echo "Instalar php"
echo "y" | sudo apt install php libapache2-mod-php

echo "Instalar paquetes adicionales php"
echo "y" | sudo apt install php-cli
echo "y" | sudo apt install php-cgi
echo "y" | sudo apt install php-mysql
echo "y" | sudo apt install php-pgsql

echo "Mover los archivos de prueba"
sudo mv /tmp/php/phpinfo.php /var/www/html/phpinfo.php
sudo mv /tmp/php/actividad_grupal.php /var/www/html/actividad_grupal.php

echo "Reiniciar el servicio apache"
sudo systemctl restart apache2.service 

echo "y" | sudo ufw enable
echo "Abrir puertos necesarios"
sudo ufw allow ssh/tcp
sudo ufw allow 'Apache'

echo "Finaliza aprovicionamiento de Apache - PHP"
#Pruebas
echo "Comproar funcionamiento ingresando a las siguientes URLs"
echo "http://localhost:8080"
echo "http://localhost:8080/phpinfo.php"
echo "http://localhost:8080/actividad_grupal.php"