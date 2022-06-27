#!/bin/bash
set -x
set -e

IP=$(ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" | head -n 1)
docker pull hello-world
docker pull busybox
docker login -u admin -p Harbor12345 $IP:5000  

docker tag hello-world $IP:5000/library/hello-world:latest
docker push $IP:5000/library/hello-world:latest
echo "$? pushed hello world"

docker tag busybox $IP:5000/library/busybox:latest
docker push $IP:5000/library/busybox:latest
echo "$? pushed busybox"