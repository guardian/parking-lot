#!/bin/bash -x

DOCKER_NAME=parking-lot:latest
ROOT_DIR=$(cd $(dirname "$0"); pwd)

# Boot docker
docker run -d -t -v $ROOT_DIR/sites:/etc/apache2/sites-enabled -p 18080:80 $DOCKER_NAME /usr/sbin/apache2 -DFOREGROUND
[ $? -gt 0 ] && exit 1

# Run test scripts
$ROOT_DIR/testing/run-tests.sh
TEST_RESULT=$?

CONTAINER_ID=$(docker ps | awk "/$DOCKER_NAME/ {print \$1}")

docker stop $CONTAINER_ID
docker rm -f $CONTAINER_ID

# Optional: remove docker container after testing
# docker rmi $DOCKER_NAME

# If not successful, terminate here
[ $TEST_RESULT -gt 0 ] && exit 1
