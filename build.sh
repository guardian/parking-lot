#!/bin/bash -x

ROOT_DIR=$(cd $(dirname "$0"); pwd)

DOCKER_NAME=parking-lot:latest
DOCKER_URI=dockreg.gutools.co.uk:8080/$DOCKER_NAME

# Boot docker
docker run -t -v $ROOT_DIR/sites:/etc/apache2/sites-enabled -p 18080:80 $DOCKER_URI /usr/sbin/apache2 -DFOREGROUND
[ $? -gt 0 ] && exit 1

# Run test scripts
$ROOT_DIR/testing/run-tests.sh
TEST_RESULT=$?

CONTAINER_ID=$(docker ps | awk "/$DOCKER_NAME/ {print \$1}")
docker stop $CONTAINER_ID
docker rm -f $CONTAINER_ID

docker rmi $DOCKER_URI

# If not successful, terminate here
[ $TEST_RESULT -gt 0 ] && exit 1

[ -d target ] && rm -rf target
mkdir target
cd target

cp -r sites .
cp deploy/deploy.json .
zip -rv artifacts.zip sites/ deploy.json

echo "##teamcity[publishArtifacts '$(pwd)/artifacts.zip => .']"
