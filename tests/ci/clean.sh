#!/bin/bash
set -x

# stop running containers
docker stop $(docker ps -aq)

# delete all containers
docker rm $(docker ps -aq)

# Clean up the image on the host
docker system prune -a -f


# Delete cache file "/data"
harbor_install_cache="/data"
if [ -d "$harbor_install_cache" ]; then
    echo "delete harbor install cache path $harbor_install_cache"
    rm -rf $harbor_install_cache
fi

harbor_cache="/harbor"
if [ -d "$harbor_cache" ]; then
    echo "delete harbor cache path $harbor_cache"
    rm -rf $harbor_cache
fi
