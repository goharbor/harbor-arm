#!/bin/bash
set -x

# stop running containers
res=$(docker ps -aq)
echo ${#res[*]}

if [ ${#res[*]} -gt 0 ]; then
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)
fi

# Clean up the image on the host 
docker system prune -a -f 


# Delete cache file "/data"
harbor_install_cache="/data"
if [ -d "$harbor_install_cache" ]; then
    echo "delete harbor install cache path $harbor_install_cache"
    rm -rf $harbor_install_cache
fi

# Delete cache file "/harbor"
harbor_cache="/harbor"
if [ -d "$harbor_cache" ]; then
    echo "delete harbor cache path $harbor_cache"
    rm -rf $harbor_cache
fi

