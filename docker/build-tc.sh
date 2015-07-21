#!/bin/bash

NAME=${TEAMCITY_BUILDCONF_NAME%-docker}

DIR=$(dirname $0)

docker build -t="working-${NAME}:${BUILD_NUMBER}" ${DIR}/

# Start container
CONTAINER_ID=$(docker run -d working-${NAME}:${BUILD_NUMBER} /bin/bash)

# Export/import container to flatten it
docker export $CONTAINER_ID | docker import - dockreg.gutools.co.uk:8080/${NAME}:${BUILD_NUMBER}

# Kill the containter
docker stop $CONTAINER_ID
docker rm -f $CONTAINER_ID

# Delete initial working image
docker rmi working-${NAME}:${BUILD_NUMBER}

IMAGE_ID=$(docker images | awk "/${NAME} +${BUILD_NUMBER}/ {print \$3}")
docker tag $IMAGE_ID dockreg.gutools.co.uk:8080/${NAME}:latest

docker push dockreg.gutools.co.uk:8080/${NAME}

# Kill any running containers now that we're finished
docker ps -a --no-trunc | grep 'Exit' | awk '{print $1}' | xargs -L 1 -r docker rm

# Clean up ALL images
docker images --no-trunc | awk '{print $3}' | grep -v IMAGE | xargs -L 1 -r docker rmi
