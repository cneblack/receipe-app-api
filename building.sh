#!/bin/bash
exit_with_error() {
    echo $1 && exit 1
}

BASE_VERSION=$(grep -Po "(?<=^VERSION = \").+(?=\")" app/app/settings.py)
DESTINATION=$1

# mkdir -p images_docker

PROJECT_NAME=receipe-app-api-app
IMAGE_NAME="$PROJECT_NAME:$BASE_VERSION"

echo -e "\n..... :: Deleting old  :: ....."
OLD_IMAGES=$(docker images | grep $PROJECT_NAME | grep latest | awk '{printf "%s:%s ", $1, $2}')
if [[ ${OLD_IMAGES} ]]; then
    docker images
    echo -e "\n..... ::Ci sono immagini latest da rimuovere"
    echo -e "\n..... :: Vecchie immagini trovate :: ....."

    for OLD_IMAGE in ${OLD_IMAGES}
    do
        echo -e "\n..... :: Vecchia immagine trovata $OLD_IMAGE :: ....."
        echo -e "\n..... :: Rimozione $OLD_IMAGE :: ....."
        echo -e "\n ..... :: docker-compose down :: ....."
        docker-compose down
        echo -e "\n ..... :: docker rmi $OLD_IMAGE :: ....."
        docker rmi $OLD_IMAGE
    done
else
    echo -e "\n..... ::Non ci sono immagini con versione latest da rimuovere"
fi


if [ $DESTINATION == "latest" ];
    then
        echo " :: ..... Versione $PROJECT_NAME:latest :: ....."
        IMAGE_NAME="$PROJECT_NAME:latest"
else
    echo " :: ..... Versione $PROJECT_NAME:$BASE_VERSION :: ....."
fi
echo -e "\n..... ::Inizio Building image:: ....."
docker build --tag "$IMAGE_NAME" .
# docker save "$IMAGE_NAME" | xz -vzf > images_docker/${IMAGE_NAME//[:.]/_}.tar.xz
docker-compose up -d
exit 0
