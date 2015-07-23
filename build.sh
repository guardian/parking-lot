#!/bin/bash

ROOT_DIR=$(cd $(dirname "$0"); pwd)

DOCKER_NAME=parking-lot
DOCKER_URI=dockreg.gutools.co.uk:8080/${DOCKER_NAME}:latest

# Boot docker - need command on the end to fix old Docker version on TC
docker run -d -t -v $ROOT_DIR/sites:/etc/apache2/sites-enabled -p 18080:80 $DOCKER_URI /bin/bash -c 'source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND'
[ $? -gt 0 ] && exit 1

sleep 5
CONTAINER_ID=$(docker ps | awk "/$DOCKER_NAME/ {print \$1}")
if [ -z $CONTAINER_ID ]; then
    echo "Can't find running container"
    exit 1
fi

# Run test scripts
$ROOT_DIR/testing/run-tests.sh
TEST_RESULT=$?

docker stop $CONTAINER_ID
docker rm -f $CONTAINER_ID
docker rmi -f $DOCKER_URI

# If not successful, terminate here
[ $TEST_RESULT -gt 0 ] && exit 1

[ -d target ] && rm -rf target
mkdir target
cd target

cp -r ${ROOT_DIR}/sites .
cp ${ROOT_DIR}/deploy/deploy.json .
zip -rv artifacts.zip sites/ deploy.json

echo "##teamcity[publishArtifacts '$(pwd)/artifacts.zip => .']"
