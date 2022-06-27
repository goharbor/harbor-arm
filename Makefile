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

# input true/false only
PULL_BASE_FROM_DOCKERHUB=false

# dockerhub user
REGISTRYUSER=
REGISTRYPASSWORD=

# downlaod goharbor/harbor source code
download:
	$(shell git clone --branch $(HARBOR_TAG) $(HARBOR_SOURCE_URL) $(SRCPATH))
	@echo "download goharbor/harbor source code success"
	
# Arm data replacement before building harbor arm
REPLACE_BUILD_FILE_PATH = make/photon/chartserver/compile.sh make/photon/exporter/Dockerfile /make/photon/notary/binary.Dockerfile
REPLACE_BUILD_FILE_PATH += make/photon/notary/builder make/photon/portal/Dockerfile make/photon/registry/Dockerfile.binary
REPLACE_BUILD_FILE_PATH += make/photon/trivy-adapter/Dockerfile.binary make/photon/Makefile make/prepare
REPLACE_BUILD_FILE_PATH += tests/ci/api_common_install.sh tests/ci/api_run.sh tests/ci/ui_ut_run.sh
REPLACE_BUILD_FILE_PATH += tests/ci/ut_install.sh tests/ci/ut_run.sh Makefile

REPLACE_BUILD_FOLDER_PATH = tools/migrate_chart tools/mockery tools/spectral tools/swagger

# Prepare data phase for building harbor arm architecture
prepare_arm_data:
	@for name in $(REPLACE_BUILD_FILE_PATH) ; \
	do \
		if [ -f $(BUILDPATH)/$$name ]; then \
			rm -f $(BUILDPATH)/$$name ; \
			cp $(CURDIR)/harbor/$$name $(BUILDPATH)/$$name; \
		else \
			echo "$(1) file non exsits" ; \
		fi ;\
	done

	@for name in $(REPLACE_BUILD_FOLDER_PATH) ; \
	do \
		if [ -d $(BUILDPATH)/$$name ]; then \
			rm -rf $(BUILDPATH)/$$name ; \
			cp -r $(CURDIR)/harbor/$$name $(BUILDPATH)/$$name ; \
		else \
			echo "$(1) folder non exsits" ; \
		fi ; \
	done

	@echo "copy clean.sh to goharbor/harbor folder"
	cp $(CURDIR)/harbor/tests/ci/clean.sh $(BUILDPATH)/tests/ci/clean.sh
    
# Rebuild the redis binary file in order to avoid the page-size problem when running on the arm64 machine
compile_redis:
	@echo $(CURDIR)
	cd $(CURDIR)/redis && $(CURDIR)/redis/rpm_builder.sh && cd - ;
	@echo "copy redis file to goharbor harbor photon redis fodler"
	cp -r $(CURDIR)/redis/. $(BUILDPATH)/make/photon/redis
	

compile: 
	cd $(SRCPATH) && make -f Makefile $(MAKE_COMPILE)

package_online:
	cd $(SRCPATH) && make -f Makefile $(MAKE_ONLINE)

.PHONY: build
build: 
	@echo "build harbor-arm image"
	cd $(SRCPATH) && make -f Makefile $(MAKE_BUILD) -e DEVFLAG=$(DEVFLAG) \
	 -e REGISTRYUSER=$(REGISTRYUSER) -e REGISTRYPASSWORD=$(REGISTRYPASSWOR) \
	 -e PULL_BASE_FROM_DOCKERHUB=$(PULL_BASE_FROM_DOCKERHUB) \
	 -e BUILD_BASE=$(BUILD_BASE) -e VERSIONTAG=$(VERSIONTAG)