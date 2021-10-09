# Copyright Project Harbor Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

*** Settings ***
Documentation  This resource provides helper functions for docker operations
Library  OperatingSystem
Library  Process

*** Keywords ***
CNAB Push Bundle
    [Arguments]  ${ip}  ${user}  ${pwd}  ${target}  ${bundle_file}  ${docker_user}  ${docker_pwd}
    ${rc}  ${output}=  Run And Return Rc And Output  ./tests/robot-cases/Group0-Util/cnab_push_bundle.sh ${ip} ${user} ${pwd} ${target} ${bundle_file} ${docker_user} ${docker_pwd}
    Log To Console  ${output}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
