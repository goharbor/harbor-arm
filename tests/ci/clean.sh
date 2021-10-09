#!/bin/bash
set -x

# harbor make path for harbor-arm
harbor_arm_path="$0/make"

# docker-compose file name
docker_compose_file="docker-compose.yml"

# docker-compose file path
docker_compose_path=$harbor_arm_path/$docker_compose_file

# Determine whether there is a deployed harbor process
if [ $(docker ps -a | grep -c "goharbor") -gt 1 ]; then
  if [ -f "$docker_compose_path" ]; then
    echo "Stop harbor process from docker-compose.yaml"
    cd $harbor_arm_path
    docker-compose down
  else
    echo "No docker-compose.yaml file"
  fi
else
    echo "No harbor process"
fi

# Determine whether the automated test process remains
if [ $(docker ps -a | grep -c "goharbor/harbor-e2e-engine") -gt 0 ]; then
  docker rm $(docker ps -qa)
else
    echo "No harbor process"
fi

# Delete cache file "/data"
harbor_cache_path="/data"
if [ -d "$harbor_cache_path" ]; then
    echo "delete harbor cache path $harbor_cache_path"
    rm -rf $harbor_cache_path/*
fi

# Delete the harbor-arm source directory
# harbor_arm_source_path="/root/actions-runner/harbor-arm-ci/harbor-arm/harbor-arm"
# if [ -d "$harbor_arm_source_path" ]; then
#     echo "delete harbor source code path $harbor_arm_source_path"
#     rm -rf $harbor_arm_source_path
# fi