#!/bin/bash
# Variables de configuración pasadas como parámetros
## ESTE SCRIPT PERMITE EJECUTAR UN SCRIPT DE BASH DENTRO DE UN CONTENEDOR DE AMAZON LINUX 2
## ESTO PERMITE AUTOMATIZAR OTRAS TAREAS EN LA NUBE DE AWS SIN TENER QUE INSTALAR LA CLI NI CONFIGURAR CREDENCIALES
## EL SCRIPT RECIBE 5 PARÁMETROS:

# AWS_ACCESS_KEY_ID: ID de la clave de acceso de AWS
# AWS_SECRET_ACCESS_KEY: Clave de acceso secreta de AWS
# AWS_DEFAULT_REGION: Región por defecto de AWS
# SCRIPT_DIR: Ruta del script de Bash a ejecutar dentro del contenedor
# SCRIPT_FILE: Ruta del archivo de configuración a pasar al script

# Verificar si se pasaron los parámetros necesarios
if [ "$#" -ne 5 ]; then
  echo "Uso: $0 <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> <AWS_DEFAULT_REGION> <SCRIPT_DIR> <SCRIPT_FILE>"
  exit 1
fi

# Asignar las variables de entorno
AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_DEFAULT_REGION=$3

# Obtener el directorio y nombre del script como parámetros
SCRIPT_DIR=$4
SCRIPT_NAME=$5


# Verificar si el directorio del script existe
if [ ! -d "$SCRIPT_DIR" ]; then
  echo "Error: El directorio del script '$SCRIPT_DIR' no existe."
  exit 1
fi

# Obtener la ruta completa del script
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

# Verificar si el script existe
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "Error: El script '$SCRIPT_PATH' no existe."
  exit 1
fi



# Ejecutar el contenedor Docker con las credenciales de AWS y el script pasado
echo "Ejecutando el script '$SCRIPT_PATH' en un contenedor de Amazon Linux 2..."
#echo "Archivo de configuración: '$CONFIG_FILE_CONTAINER_PATH'"
echo "AWS_ACCESS_KEY_ID: '$AWS_ACCESS_KEY_ID'"
echo "AWS_SECRET_ACCESS_KEY: '$AWS_SECRET_ACCESS_KEY'"
echo "AWS_DEFAULT_REGION: '$AWS_DEFAULT_REGION'"


docker run --rm \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
  -v "$SCRIPT_DIR":/scripts \
  amazonlinux:2 \
  bash -c "cd /scripts && bash $SCRIPT_NAME  /scripts/config.cfg"
