#!/bin/bash

ROOT_DIR=$(cd $(dirname "$0"); pwd)
DOCKER_NAME=parking-lot:latest

# Boot docker
echo "Booting container..."
docker run -d -t -v $ROOT_DIR/sites:/etc/apache2/sites-enabled -p 18080:80 $DOCKER_NAME >/dev/null

if [ $? -eq 0 ]; then
    sleep 2
    CONTAINER_ID=$(docker ps | awk "/$DOCKER_NAME/ {print \$1}")
    if [ -z $CONTAINER_ID ]; then
        echo "Can't find running container"
    else
        # Run test scripts
        echo "Running tests..."
        $ROOT_DIR/testing/run-tests.sh
    fi
fi

echo "Cleaning up..."
if [ ! -z $CONTAINER_ID ]; then
    docker stop $CONTAINER_ID >/dev/null
    docker rm -f $CONTAINER_ID >/dev/null
fi

# Optional: remove docker container after testing
# docker rmi $DOCKER_NAME
