#!/bin/bash

ROOT_DIR=$(cd $(dirname "$0"); pwd)

DOCKER_NAME=dockreg.gutools.co.uk:8080/parking-lot:latest

######## Run tests ########

# Boot docker
CONTAINTER_ID=$(docker run -t -v $ROOT_DIR/../sites:/etc/apache2/sites-enabled -p 18080:80 $DOCKER_NAME)

# Run test scripts
testing/run-tests.sh
TEST_RESULT=$?

docker stop $CONTAINER_ID
docker rm -f $CONTAINER_ID

# Optional: remove docker container after testing
# docker rmi $DOCKER_NAME

# If not successful, terminate here
[ $TEST_RESULT -gt 0 ] && exit 1

[ -d target ] && rm -rf target
mkdir target
cd target

cp -r sites .
cp deploy/deploy.json .
zip -rv artifacts.zip sites/ deploy.json

echo "##teamcity[publishArtifacts '$(pwd)/artifacts.zip => .']"
