# Copyright Project Harbor Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Makefile for Harbor-arm project
#
# Targets:
#
# all: 
# _update_makefile:              replace goharbor/harbor's makefile for build harbor-arm.
#
# _update_make_photon_makefile:  replace goharbor/harbor's photon makefile.
#
# _update_chartserver:           replace goharbor/harbor's chartserver 
#
# _update_registry:              replace goharbor/harbor's registry
#
# _update_trivy-adapter:         replace goharbor/harbor's trivy-adapter
#
# _update_portal:                replace goharbor/harbor's portal 
#
# _update_notary:                replace goharbor/harbor's notary
# 
# pre_update: 
#
# download:
# 
# compile:
#
# build_base_image:
#
# build:


BUILDPATH=$(CURDIR)/src/github.com/goharbor/harbor

# default goharbor/harbor make path
HARBOR_MAKEFILE_PATH=$(BUILDPATH)/Makefile
HARBOR_PHOTON_MAKEFILE_PATH=$(BUILDPATH)/make/photon/Makefile
HARBOR_PHOTON_CHARTSERVER_COMPILE_PATH=$(BUILDPATH)/make/photon/chartserver/compile.sh
HARBOR_PHOTON_REGISTRY_DOCKERFILE_PATH=$(BUILDPATH)/make/photon/registry/Dockerfile.binary
HARBOR_PHOTON_TRIVY-ADAPTER_DOCKERFILE_PATH=$(BUILDPATH)/make/photon/trivy-adapter/Dockerfile.binary
HARBOR_PHOTON_NOTARY_DOCKERFILE_PATH=$(BUILDPATH)/make/photon/notary/binary.Dockerfile
HARBOR_PHOTON_NOTARY_BUILDER_PATH=$(BUILDPATH)/make/photon/notary/builder
HARBOR_PHOTON_PORTAL_DOCKERFILE_PATH=$(BUILDPATH)/make/photon/portal/Dockerfile
HARBOR_PHOTON_EXPORTER_PATH=$(BUILDPATH)/make/photon/exporter/Dockerfile
HARBOR_PUSHIMAGE_PATH=$(BUILDPATH)/make/pushimage.sh

# download goharbor/harbor parammeters
HARBOR_SOURCE_URL=https://github.com/goharbor/harbor.git
SRCPATH=src/github.com/goharbor/harbor
HARBOR_TAG=release-2.3.0

# makefile path
MAKEPATH=$(BUILDPATH)/make

# make target
MAKE_COMPILE=compile
MAKE_BUILD_BASE=build_base_docker
MAKE_ONLINE=package_online
MAKE_OFFLINE=package_offline
MAKE_BUILD=build

# parameters
BUILD_PG96=true
DEVFLAG=true
BUILDBIN=true

# package
TARCMD=$(shell which tar)
ZIPCMD=$(shell which gzip)
DOCKERIMGFILE=harbor-arm
HARBORPKG=harbor-arm


# for docker image tag
VERSIONTAG=dev-arm
BASEIMAGETAG=dev-arm
BUILD_BASE=true
PUSHBASEIMAGE=false
BASEIMAGENAMESPACE=goharbor

# #input true/false only
PULL_BASE_FROM_DOCKERHUB=true

# sed location
SEDCMD=$(shell which sed)
SEDCMDI=$(SEDCMD) -i
ifeq ($(shell uname),Darwin)
    SEDCMDI=$(shell which gsed) -i
endif

# dockerhub user
REGISTRYUSER=
REGISTRYPASSWORD=

_update_makefile:
	@echo "update goharbor makefile"
	@$(SEDCMDI) 's/--rm/--rm --env CGO_ENABLED=0 --env GOOS=linux --env GOARCH=arm64/g' $(HARBOR_MAKEFILE_PATH);
	@$(SEDCMDI) 's/$$(DOCKERBUILD)/docker buildx build --platform linux\/arm64 --progress plain --output=type=docker/g' $(HARBOR_MAKEFILE_PATH);
	@$(SEDCMDI) 's/gen_apis: lint_apis/gen_apis:/g' $(HARBOR_MAKEFILE_PATH);
	@$(SEDCMDI) 's/_Linux-64bit.tar.gz/_Linux-ARM64.tar.gz/g' $(HARBOR_MAKEFILE_PATH);
	@$(SEDCMDI) 's/_Linux_x86_64.tar.gz/_Linux_arm64.tar.gz/g' $(HARBOR_MAKEFILE_PATH);
	@$(SEDCMDI) 's/VERSIONTAG=dev/VERSIONTAG=dev-arm/g' $(HARBOR_MAKEFILE_PATH);
	@$(SEDCMDI) 's/BASEIMAGETAG=dev/BASEIMAGETAG=dev-arm/g' $(HARBOR_MAKEFILE_PATH);
	@$(SEDCMDI) 's/BUILD_PG96=true/BUILD_PG96=false/g' $(HARBOR_MAKEFILE_PATH);
	

_update_make_photon_makefile:
	@echo "update goharbor photon makefile"
	@$(SEDCMDI) 's/$(DOCKERCMD) build/$(DOCKERCMD) buildx build --platform linux\/arm64 --progress plain --output=type=docker/' $(HARBOR_PHOTON_MAKEFILE_PATH)
	@$(SEDCMDI) '219 a \ \ \ \ \ \ \ \ docker buildx prune -f ; \\' $(HARBOR_PHOTON_MAKEFILE_PATH)

_update_chartserver:
	@echo "update goharbor chartserver compile.sh"
	@$(SEDCMDI) 's/go build -a/GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -a/g' $(HARBOR_PHOTON_CHARTSERVER_COMPILE_PATH)

_update_registry:
	@echo "update goharbor registry Dockerfile.binary"
	@$(SEDCMDI) 's/CGO_ENABLED=0/GOOS=linux GOARCH=arm64 CGO_ENABLED=0/g' $(HARBOR_PHOTON_REGISTRY_DOCKERFILE_PATH)

_update_trivy-adapter:
	@echo "update goharbor trivy-adapter Dockerfile.binary"
	@$(SEDCMDI) 's/CGO_ENABLED=0/GOARCH=arm64 CGO_ENABLED=0/g' $(HARBOR_PHOTON_TRIVY-ADAPTER_DOCKERFILE_PATH)

_update_portal:
	@echo "update goharbor portal Dockerfile"
	@$(SEDCMDI) 's/node:15.4.0/--platform=$${BUILDPLATFORM:-linux\/amd64} node:15.4.0/g' $(HARBOR_PHOTON_PORTAL_DOCKERFILE_PATH);
	@$(SEDCMDI) "s/'node_modules\/@angular\/cli\/bin\/ng'/.\/node_modules\/@angular\/cli\/bin\/ng/g" $(HARBOR_PHOTON_PORTAL_DOCKERFILE_PATH)

_update_notary:
	@echo "update goharbor notary binary.Dockerfile"
	@$(SEDCMDI) '8 a ENV CGO_ENABLED 0 \nENV GOOS linux \nENV GOARCH arm64' $(HARBOR_PHOTON_NOTARY_DOCKERFILE_PATH)
	@echo "update goharbor notary builder"
	@$(SEDCMDI)	's/docker build/docker buildx build --platform linux\/arm64 --progress plain --output=type=docker/g' $(HARBOR_PHOTON_NOTARY_BUILDER_PATH)

_update_exporter:
	@echo "update goharbor exporter Dockerfile"
	@$(SEDCMDI) 's/ENV GOARCH=amd64/ENV GOARCH=arm64/g' $(HARBOR_PHOTON_EXPORTER_PATH)




pre_update: _update_makefile _update_make_photon_makefile _update_chartserver _update_registry _update_trivy-adapter _update_notary _update_portal _update_exporter

# downlaod goharbor/harbor source code
download:
	$(shell git clone --branch $(HARBOR_TAG) $(HARBOR_SOURCE_URL) $(SRCPATH))
	@echo "download goharbor/harbor source code success"
	
# Arm data replacement before building harbor arm
prepare_arm_data:
	@echo "copy tools fodler to goharbor/harbor/tools fodler"
	cp -r $(CURDIR)/tools/. $(BUILDPATH)/tools/
	@echo "copy tests bash fodler to goharbor/harbor/tests fodler"
	cp -r $(CURDIR)/tests/. $(BUILDPATH)/tests/
	@echo "copy make/prepare file to goharbor/harbor/make fodler"
	cp -r $(CURDIR)/make/. $(BUILDPATH)/make/

# Rebuild the redis binary file in order to avoid the page-size problem when running on the arm64 machine
compile_redis:
	@echo $(CURDIR)
	cd $(CURDIR)/redis && $(CURDIR)/redis/rpm_builder.sh && cd - ;
	@echo "copy redis file to goharbor harbor photon redis fodler"
	cp -r $(CURDIR)/redis/. $(BUILDPATH)/make/photon/redis
	

compile: 
	cd $(SRCPATH) && make -f Makefile $(MAKE_COMPILE)

build_base_image: 
	cd $(SRCPATH) && make -f Makefile $(MAKE_BUILD_BASE) \
	 -e BASEIMAGETAG=$(BASEIMAGETAG) -e BASEIMAGENAMESPACE=$(BASEIMAGENAMESPACE)  \
	 -e REGISTRYUSER=$(REGISTRYUSER) -e REGISTRYPASSWORD=$(REGISTRYPASSWORD) -e BUILD_PG96=$(BUILD_PG96)

package_online:
	cd $(SRCPATH) && make -f Makefile $(MAKE_ONLINE)

.PHONY: build
build: 
	@echo "build harbor-arm image"
	cd $(SRCPATH) && make -f Makefile $(MAKE_BUILD) -e DEVFLAG=$(DEVFLAG) \
	 -e REGISTRYUSER=$(REGISTRYUSER) -e REGISTRYPASSWORD=$(REGISTRYPASSWOR) \
	 -e PULL_BASE_FROM_DOCKERHUB=$(PULL_BASE_FROM_DOCKERHUB) \
	 -e BUILD_BASE=$(BUILD_BASE) -e VERSIONTAG=$(VERSIONTAG)