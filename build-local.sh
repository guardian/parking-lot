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
        if [ $? -eq 0 ]; then
            # Build working directory
            [ -d build ] && rm -rf build
            mkdir -p build/parking-lot
            cd build

            # Add build files
            cp -r ${ROOT_DIR}/sites parking-lot/

            echo "Building artifact..."
            cd $ROOT_DIR/build
            tar -zcvf $ROOT_DIR/build/parking-lot.tar.gz parking-lot/
            echo "${BUILD_NUMBER} ${BUILD_VCS_NUMBER}" > $ROOT_DIR/build/parking-lot-version.txt
            sha256sum $ROOT_DIR/build/parking-lot.tar.gz | awk '{print $1}' > $ROOT_DIR/build/parking-lot.sha256
            rm -fr $ROOT_DIR/build/parking-lot/

            #echo "Uploading to S3..."
            #aws s3 cp $ROOT_DIR/build/parking-lot.tar.gz s3://parking-lot/CODE/parking-lot.tar.gz
            #aws s3 cp $ROOT_DIR/build/parking-lot-version.txt s3://parking-lot/CODE/parking-lot-version.txt
            #aws s3 cp $ROOT_DIR/build/parking-lot.sha256 s3://parking-lot/CODE/parking-lot.sha256
        fi
    fi
fi

echo "Cleaning up..."
if [ ! -z $CONTAINER_ID ]; then
    docker stop $CONTAINER_ID >/dev/null
    docker rm -f $CONTAINER_ID >/dev/null
fi

# Optional: remove docker container after testing
# docker rmi $DOCKER_NAME
