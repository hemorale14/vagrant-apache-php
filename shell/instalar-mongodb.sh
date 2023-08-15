#!/bin/bash

set -e

logger "Arrancando instalacion y configuracion de MongoDB"
USO="Uso : instalar-mongodb.sh [opciones]
Ejemplo:
instalar-mongodb.sh -f archivo ini
Opciones:
-f archivo ini
-a muestra esta ayuda
"
function ayuda() {
echo "${USO}"
if [[ ${1} ]]
then
echo ${1}
fi
}

# Gestionar los argumentos
# -f archivo ini
while getopts ":f:a" OPCION
do
case ${OPCION} in
f ) file=$OPTARG
while IFS="=" read -r key value; do
  case "$key" in
       "user") USUARIO="${value}";;
       "password") PASSWORD="$value";;
       "port") PUERTO_MONGOD="$value";;
  esac
done < "$file"
;;
: ) ayuda "Falta el parametro para -$OPTARG"; exit 1;; \?) ayuda "La opcion no existe : $OPTARG"; exit 1;;
esac
done

if [ -z ${USUARIO} ]
then
  ayuda "El usuario (user) debe ser especificadod dentro del archivo .ini"; exit 1
fi

if [ -z ${PASSWORD} ]
then
ayuda "La password (password) debe ser especificada dentrodel archivo .ini"; exit 1
fi

if [ -z ${PUERTO_MONGOD} ]
then
PUERTO_MONGOD=27017
fi

# Obtén la clave de MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/mongodb-org-4.2.gpg > /dev/null


# Obtener la versión de Ubuntu
ubuntu_version=$(lsb_release -cs)

# Agregar el repositorio según la versión de Ubuntu detectada
if [[ "$ubuntu_version" == "xenial" ]]; then
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
elif [[ "$ubuntu_version" == "bionic" ]]; then
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
else
    echo "La versión actual de Ubuntu no es compatible con MongoDB 4.2.24."
    exit 1
fi

if [[ -z "$(mongo --version 2> /dev/null | grep '4.2.24')" ]]
then
# Instalar paquetes comunes, servidor, shell, balanceador de shards y herramientas
apt-get -y update \
&& apt-get install -y \
mongodb-org=4.2.24 \
mongodb-org-server=4.2.24 \
mongodb-org-shell=4.2.24 \
mongodb-org-mongos=4.2.24 \
mongodb-org-tools=4.2.24 \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /var/lib/mongodb
fi
# Crear las carpetas de logs y datos con sus permisos
[[ -d "/datos/bd" ]] || mkdir -p -m 755 "/datos/bd"
[[ -d "/datos/log" ]] || mkdir -p -m 755 "/datos/log"
# Establecer el dueño y el grupo de las carpetas db y log
chown mongodb /datos/log /datos/bd
chgrp mongodb /datos/log /datos/bd
# Crear el archivo de configuración de mongodb con el puerto solicitado
mv /etc/mongod.conf /etc/mongod.conf.orig
(
cat <<MONGOD_CONF
# /etc/mongod.conf
systemLog:
  destination: file
  path: /datos/log/mongod.log
  logAppend: true
storage:
  dbPath: /datos/bd
  engine: wiredTiger
  journal:
    enabled: true
net:
  port: ${PUERTO_MONGOD}
security:
  authorization: enabled
MONGOD_CONF
) > /etc/mongod.conf

# Reiniciar el servicio de mongod para aplicar la nueva configuracion
systemctl restart mongod


#Instalar netstat para validar este escuchando el puerto de la BD
sudo apt-get install netcat-openbsd > /dev/null

#Intentar crear usuario si la BD esta ya disponible despues de 10 intentos si el puerto del servicio no responde finaliza el programa 
finished=false
contador=1
while ! $finished; do
    sleep 1
    nc -z localhost ${PUERTO_MONGOD}
    if [[ $?  -eq 0 ]]; then
      echo "MONGO service is working"
      finished=true
      # Crear usuario con la password proporcionada como parametro
      mongo admin << CREACION_DE_USUARIO
      db.createUser({
      user: "${USUARIO}",
      pwd: "${PASSWORD}",
      roles:[{
      role: "root",
      db: "admin"
      },{
      role: "restore",
      db: "admin"
      }] })
CREACION_DE_USUARIO
      logger "El usuario ${USUARIO} ha sido creado con exito!"
      echo "El usuario ${USUARIO} ha sido creado con exito!"
    elif [[ $contador -eq 100 ]]; then
      echo "MONGO service "
      finished=true
    else
      echo "MONGO service is not working"
      let contador=contador+1
      echo "$contador"
    fi
done

exit 0
