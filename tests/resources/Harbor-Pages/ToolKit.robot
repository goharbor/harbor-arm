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
Documentation  This resource provides any keywords related to the Harbor private registry appliance
Resource  ../../resources/Util.robot

*** Variables ***

*** Keywords ***
Delete Success
    [Arguments]  @{obj}
    FOR  ${obj}  IN  @{obj}
        Retry Wait Until Page Contains Element  //*[@id='contentAll']//div[contains(.,'${obj}')]/../div/clr-icon[@shape='success-standard']
    END
    Sleep  1

Delete Fail
    [Arguments]  @{obj}
    FOR  ${obj}  IN  @{obj}
        Retry Wait Until Page Contains Element  //*[@id='contentAll']//div[contains(.,'${obj}')]/../div/clr-icon[@shape='error-standard']
    END
    Sleep  1

Filter Object
#Filter project repo user tag.
    [Arguments]    ${kw}
    Retry Element Click  xpath=//hbr-filter//clr-icon
    ${element}=  Set Variable  xpath=//hbr-filter//input
    Wait Until Element Is Visible And Enabled  ${element}
    Retry Clear Element Text  ${element}
    Retry Text Input   ${element}  ${kw}
    Sleep  3

Filter Project
#Filter project repo user tag.
    [Arguments]    ${kw}
    Retry Element Click  ${log_xpath}
    Retry Element Click  ${projects_xpath}
    Filter Object  ${kw}

Select Object
#select single element such as user project repo tag
    [Arguments]    ${obj}
    Retry Element Click  xpath=//clr-dg-row[contains(.,'${obj}')]//label

Multi-delete Object
    [Arguments]    ${delete_btn}  @{obj}
    FOR  ${obj}  IN  @{obj}
        ${element}=  Set Variable  xpath=//clr-dg-row[contains(.,'${obj}')]//label
        Retry Element Click  ${element}
    END
    Sleep  1
    Retry Element Click  ${delete_btn}
    Sleep  1
    Retry Element Click  ${repo_delete_on_card_view_btn}
    Sleep  1
    Sleep  1

# This func cannot support as the delete user flow changed.
Multi-delete Artifact
    [Arguments]    ${delete_btn}  @{obj}
    FOR  ${obj}  IN  @{obj}
        ${element}=  Set Variable  xpath=//clr-dg-row[contains(.,'${obj}')]//label
        Retry Element Click  ${element}
    END
    Sleep  1
    Retry Element Click  ${artifact_action_xpath}
    Sleep  1
    Retry Element Click  ${artifact_action_delete_xpath}
    Sleep  1
    Retry Element Click  ${repo_delete_on_card_view_btn}
    Sleep  1
    Sleep  1

Multi-delete User
    [Arguments]    @{obj}
    FOR  ${obj}  IN  @{obj}
        Retry Element Click  //clr-dg-row[contains(.,'${obj}')]//label
    END
    Retry Element Click  ${member_action_xpath}
    Retry Element Click  //*[@id='deleteUser']
    Retry Double Keywords When Error  Retry Element Click  ${delete_btn}  Retry Wait Until Page Not Contains Element  ${delete_btn}


Multi-delete Member
    [Arguments]    @{obj}
    FOR  ${obj}  IN  @{obj}
        Retry Element Click  //clr-dg-row[contains(.,'${obj}')]//clr-checkbox-wrapper/label
    END
    Retry Double Keywords When Error  Retry Element Click  ${member_action_xpath}  Retry Wait Until Page Contains Element  ${delete_action_xpath}
    Retry Double Keywords When Error  Retry Element Click  ${delete_action_xpath}  Retry Wait Until Page Contains Element  ${delete_btn}
    Retry Double Keywords When Error  Retry Element Click  ${delete_btn}  Retry Wait Until Page Not Contains Element  ${delete_btn}


Multi-delete Object Without Confirmation
    [Arguments]    @{obj}
    FOR  ${obj}  IN  @{obj}
        Retry Element Click  //clr-dg-row[contains(.,'${obj}')]//label
    END
    Retry Double Keywords When Error  Retry Element Click  ${delete_btn_2}  Retry Wait Until Page Not Contains Element  ${delete_btn_2}


Select All On Current Page Object
    Retry Element Click  //div[@class='datagrid-head']//label
