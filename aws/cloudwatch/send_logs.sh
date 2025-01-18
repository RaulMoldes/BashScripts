## aws/cloudwatch/send_logs.sh


## CONFIGURAR AWS_CLI
yum install -y aws-cli && aws configure set default.region $AWS_DEFAULT_REGION

## LEER ARCHIVO DE CONFIGURACIÓN

CONFIG_FILE=$1

# Verificar que se pase un archivo de configuración como parámetro
if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_de_configuración>"
    exit 1
fi

# Cargar variables desde el archivo de configuración
source "$CONFIG_FILE"

# Verificar que las variables estén definidas
REQUIRED_VARS=(
   LOG_GROUP_NAME LOG_STREAM_NAME LOG_FILE
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: La variable $var no está definida en el archivo de configuración."
        exit 2
    fi
done


aws logs create-log-group --log-group-name "$LOG_GROUP_NAME"

aws logs create-log-stream --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME"

# Leer el archivo de logs y enviarlos a CloudWatch
echo "Enviando logs a CloudWatch desde $LOG_FILE..."

while IFS= read -r line; do
    aws logs put-log-events \
        --log-group-name "$LOG_GROUP_NAME" \
        --log-stream-name "$LOG_STREAM_NAME" \
        --log-events timestamp=$(date +%s000),message="$(echo "$line" | tr -d '[]')"
done < "$LOG_FILE"

exit 0