#!/bin/bash

ROOT_DIR=$(cd $(dirname "$0"); pwd)

DOCKER_NAME=parking-lot
DOCKER_URI=dockreg.gutools.co.uk:8080/${DOCKER_NAME}:latest

CONTAINER_ID=$(docker ps | awk "/$DOCKER_NAME/ {print \$1}")
if [ -z $CONTAINER_ID ]; then
    echo "No running container"
else
    echo "Cleaning up container: $CONTAINER_ID"
    # Stop and clean up any running container
    docker stop $CONTAINER_ID
    docker rm -f $CONTAINER_ID
fi

# Clean up Docker image file
docker rmi -f $DOCKER_URI

exit 0
