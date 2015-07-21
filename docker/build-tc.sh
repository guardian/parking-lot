docker build -t="working-${TEAMCITY_BUILDCONF_NAME}:${BUILD_NUMBER}" .

# Start container
CONTAINER_ID=$(docker run -d working-${TEAMCITY_BUILDCONF_NAME}:${BUILD_NUMBER} /bin/bash)

# Export/import container to flatten it
docker export $CONTAINER_ID | docker import - dockreg.gutools.co.uk:8080/${TEAMCITY_BUILDCONF_NAME}:${BUILD_NUMBER}

# Kill the containter
docker stop $CONTAINER_ID
docker rm -f $CONTAINER_ID

# Delete initial working image
docker rmi working-${TEAMCITY_BUILDCONF_NAME}:${BUILD_NUMBER}

IMAGE_ID=$(docker images | awk "/${TEAMCITY_BUILDCONF_NAME} +${BUILD_NUMBER}/ {print \$3}")
docker tag $IMAGE_ID dockreg.gutools.co.uk:8080/${TEAMCITY_BUILDCONF_NAME}:latest

docker push dockreg.gutools.co.uk:8080/${TEAMCITY_BUILDCONF_NAME}

# Kill any running containers now that we're finished
docker ps -a --no-trunc | grep 'Exit' | awk '{print $1}' | xargs -L 1 -r docker rm

# Clean up ALL images
docker images --no-trunc | awk '{print $3}' | grep -v IMAGE | xargs -L 1 -r docker rmi
