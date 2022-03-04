# harbor-arm
Build Harbor for arm architecture.


## Build
<hr>

**System Requirements:**

**On a Linux host**: docker 19+  and support docker buildx

Before you build the harbor arm image, you need to check if your local environment supports docker buildx

By running the command `docker buildx ls`，If the result shows `linux/arm64`, it proves that the arm image can be built

## Get Started
```
# first step: clone harbor ARM code
git clone https://github.com/goharbor/harbor-arm.git

# execute build command：Download harbor source code
cd harbor-arm && make download

# compile redis:
make compile_redis

# Prepare to build arm architecture image data:
make prepare_arm_data

# Replace build arm image parameters：
make pre_update

# Compile harbor components:
make compile COMPILETAG=compile_golangimage

# Build harbor arm image:
make build GOBUILDTAGS="include_oss include_gcs" BUILDBIN=true NOTARYFLAG=true TRIVYFLAG=true CHARTFLAG=true GEN_TLS=true PULL_BASE_FROM_DOCKERHUB=false


```





