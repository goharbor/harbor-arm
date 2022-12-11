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
#
# download:
# 
# compile:
#


BUILDPATH=$(CURDIR)/src/github.com/goharbor/harbor

# download goharbor/harbor parammeters
HARBOR_SOURCE_URL=https://github.com/Jeremy-boo/harbor.git
SRCPATH=src/github.com/goharbor/harbor
HARBOR_TAG=feat/harbor_arm_build_make_to_main

# makefile path
MAKEPATH=$(BUILDPATH)/make

# downlaod goharbor/harbor source code
download:
	$(shell git clone --branch $(HARBOR_TAG) $(HARBOR_SOURCE_URL) $(SRCPATH))
	@echo "download goharbor/harbor source code success"

# Rebuild the redis binary file in order to avoid the page-size problem when running on the arm64 machine
compile_redis:
	@echo $(CURDIR)
	cd $(CURDIR)/redis && $(CURDIR)/redis/rpm_builder.sh && cd - ;
	@echo "copy redis file to goharbor harbor photon redis fodler"
	cp -r $(CURDIR)/redis/. $(BUILDPATH)/make/photon/redis