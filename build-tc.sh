#!/bin/bash -x

set -e

ROOT_DIR=$(cd $(dirname "$0"); pwd)

DOCKER_NAME=parking-lot
DOCKER_URI=dockreg.gutools.co.uk:8080/${DOCKER_NAME}:latest

# Boot docker - need command on the end to fix old Docker version on TC
docker run -d -t -v $ROOT_DIR/sites:/etc/apache2/sites-enabled -p 18080:80 $DOCKER_URI /bin/bash -c 'source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND'

sleep 2
CONTAINER_ID=$(docker ps | awk "/$DOCKER_NAME/ {print \$1}")
if [ -z $CONTAINER_ID ]; then
    echo "Can't find running container"
    exit 1
fi

# Run test scripts
$ROOT_DIR/testing/run-tests.sh

if [ $? -eq 0 ]; then
    # Build working directory
    [ -d $ROOT_DIR/build ] && rm -rf $ROOT_DIR/build
    mkdir -p $ROOT_DIR/build/parking-lot
    cd $ROOT_DIR/build

    # Add build files
    cp -r ${ROOT_DIR}/sites $ROOT_DIR/build/parking-lot/

    echo "Building artifact..."
    cd $ROOT_DIR/build
    tar -zcvf $ROOT_DIR/build/parking-lot.tar.gz parking-lot/
    echo "${BUILD_NUMBER} ${BUILD_VCS_NUMBER}" > $ROOT_DIR/build/parking-lot-version.txt
    sha256sum $ROOT_DIR/build/parking-lot.tar.gz | awk '{print $1}' > $ROOT_DIR/build/parking-lot.sha256
    rm -fr $ROOT_DIR/build/parking-lot/

    echo "Uploading to S3..."
    aws s3 cp $ROOT_DIR/build/parking-lot.tar.gz s3://parking-lot/PROD/parking-lot.tar.gz
    aws s3 cp $ROOT_DIR/build/parking-lot-version.txt s3://parking-lot/PROD/parking-lot-version.txt
    aws s3 cp $ROOT_DIR/build/parking-lot.sha256 s3://parking-lot/PROD/parking-lot.sha256
fi
