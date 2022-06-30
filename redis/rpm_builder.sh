#!/bin/bash

set -e

name='redis'
version='6.0.15'
core_branch='release-2.3.0'

function checkdep {
	if ! wget --version &> /dev/null
	then
		echo "Need to install wget first and run this script again."
		exit 1
	fi
}

checkdep

cur=$PWD
workDir=`mktemp -d ${TMPDIR-/tmp}/$name.XXXXXX`
mkdir -p $workDir && cd $workDir

# step 1: get source code of redis
wget http://download.redis.io/releases/$name-$version.tar.gz

# step 2: get redis-conf.patch from upstream
wget https://raw.githubusercontent.com/vmware/photon/4.0/SPECS/redis/redis-conf.patch

# step 3: get spec builder script, and replace version to 4, then to build the redis rpm packages
wget https://raw.githubusercontent.com/vmware/photon/4.0/tools/scripts/build_spec.sh
sed "s|VERSION=3|VERSION=4|g" -i build_spec.sh
chmod 755 ./build_spec.sh && cp $cur/redis.spec .

# step 4: build redis rpm.
./build_spec.sh ./redis.spec
cp ./stage/RPMS/aarch64/$name-debuginfo-$version-1.ph4.aarch64.rpm $cur
cp ./stage/RPMS/aarch64/$name-$version-1.ph4.aarch64.rpm $cur

# clean
cd $cur && rm -rf $workDir
