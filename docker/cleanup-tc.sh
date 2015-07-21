#!/bin/bash -x

# Kill any running containers now that we're finished
docker ps -a --no-trunc | grep 'Exit' | awk '{print $1}' | xargs -L 1 -r docker rm

# Clean up ALL images
docker images --no-trunc | awk '{print $3}' | grep -v IMAGE | xargs -L 1 -r docker rmi

