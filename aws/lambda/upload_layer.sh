# bin/bash

# This script is used to upload a layer to AWS Lambda

# Load the configuration



source "./config.cfg"

echo $LIBRARY_NAME
echo $LAYER_RUNTIME
echo $LAYER_ZIP_FILE

echo "Creating the ZIP file with the layer..."

# Check if the required variables are defined
REQUIRED_VARS=(
    LIBRARY_NAME LAYER_NAME LAYER_RUNTIME LAYER_ZIP_FILE
)

for var in "${REQUIRED_VARS[@]}"; do
   if [ -z "${!var}" ]; then
       echo "Error: The variable $var is not defined in the configuration file."
       exit 2
   fi
done

##INSTALLING THE PYTHON RUNTIME
echo "Installing the Python runtime..."

yum install -y $LAYER_RUNTIME python3-pip zip

echo "Installing venv..."

# python3 -m pip install --upgrade pip
pip3 install virtualenv



## CREATE A VIRTUAL ENVIRONMENT

echo "Creating a virtual environment..."


# Install the required packages
echo "Installing the required packages..."

echo $LIBRARY_NAME > requirements.txt

mkdir $LAYER_NAME
cd $LAYER_NAME
python3 -m venv venv
source venv/bin/activate
pip install -r ../requirements.txt

# Deactivate the virtual environment
deactivate

# Create a ZIP file with the layer
echo "Creating the ZIP file with the layer..."

mkdir -p python/lib/$LAYER_RUNTIME/site-packages
cp -r venv/lib/$LAYER_RUNTIME/site-packages/* python/lib/$LAYER_RUNTIME/site-packages
cp -r venv/lib64/$LAYER_RUNTIME/site-packages/* python/lib/$LAYER_RUNTIME/site-packages

zip -r9 $LAYER_ZIP_FILE python

## CREAR CARPETA /layers
mkdir -p layers

## MOVER EL ZIP A LA CARPETA /layers
mv $LAYER_ZIP_FILE layers

## PUBLICAR A AWS LAMBDA
echo "Uploading the layer to AWS Lambda..."

aws lambda publish-layer-version \
    --layer-name $LAYER_NAME \
    --description "$LAYER_DESCRIPTION" \
    --compatible-runtimes $LAYER_RUNTIME \
   --zip-file fileb://layers/$LAYER_ZIP_FILE

# Clean up
echo "Cleaning up..."

cd ..
rm -rf $LIBRARY_NAME
rm "requirements.txt"

echo "Done."

exit 0
