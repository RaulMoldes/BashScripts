#!/bin/bash
# Variables de configuración pasadas como parámetros
CONFIG_FILE=$1

# Verificar que se han pasado todos los parámetros
# Verificar que se pase un archivo de configuración como parámetro
if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_de_configuración>"
    exit 1
fi


# Cargar variables desde el archivo de configuración
source "$CONFIG_FILE"


# Imagen de Docker con la CLI de PostgreSQL
DOCKER_IMAGE="postgres:latest"

# Verificar que las variables estén definidas
REQUIRED_VARS=(
    SOURCE_DB_HOST SOURCE_DB_PORT SOURCE_DB_NAME SOURCE_DB_USER SOURCE_DB_PASSWORD
    TARGET_DB_HOST TARGET_DB_PORT TARGET_DB_NAME TARGET_DB_USER TARGET_DB_PASSWORD
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: La variable $var no está definida en el archivo de configuración."
        exit 2
    fi
done


# Archivo temporal para el volcado
DUMP_FILE="/tmp/backup_$(date +%Y%m%d%H%M%S).dump"

# Exportar contraseña de la base de datos origen
export PGPASSWORD=$SOURCE_DB_PASSWORD


## Ejecutar pg_dump en un contenedor de Docker
docker run --rm \
    -e PGPASSWORD=$SOURCE_DB_PASSWORD \
    -v /tmp:/tmp \
    $DOCKER_IMAGE \
    pg_dump -h $SOURCE_DB_HOST -p $SOURCE_DB_PORT -U $SOURCE_DB_USER -F c -b -v -f $DUMP_FILE $SOURCE_DB_NAME

if [ $? -ne 0 ]; then
    echo "Error al crear el volcado de la base de datos origen."
    exit 2
fi

echo "Volcado creado: $DUMP_FILE"

# Exportar contraseña de la base de datos destino
export PGPASSWORD=$TARGET_DB_PASSWORD

echo "Restaurando el volcado en la base de datos destino..."

# Ejecutar pg_restore en un contenedor de Docker
docker run --rm \
    -e PGPASSWORD=$TARGET_DB_PASSWORD \
    -v /tmp:/tmp \
    $DOCKER_IMAGE \
    pg_restore -h $TARGET_DB_HOST -p $TARGET_DB_PORT -U $TARGET_DB_USER -d $TARGET_DB_NAME --no-owner --no-acl -v $DUMP_FILE

if [ $? -ne 0 ]; then
    echo "Error al restaurar el volcado en la base de datos destino."
    exit 1
fi

echo "Restauración completada con éxito."

# Eliminar archivo temporal
rm -f $DUMP_FILE
echo "Archivo de volcado eliminado: $DUMP_FILE"

exit 0