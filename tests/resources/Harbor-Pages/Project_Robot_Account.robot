*** Settings ***

Resource  ../../resources/Util.robot

*** Variables ***

*** Keywords ***
Switch To Project Robot Account
    #Switch To Project Tab Overflow
    Retry Element Click  ${project_robot_account_tabpage}
    Retry Wait Until Page Contains Element  ${project_robot_account_create_btn}

Create A Robot Account And Return Token
    [Arguments]    ${projectname}    ${robot_account_name}    ${project_has_image}=${false}
    Go Into Project    ${projectname}    has_image=${project_has_image}
    Switch To Project Robot Account
    Retry Element Click    ${project_robot_account_create_btn}
    Retry Text Input    ${project_robot_account_create_name_input}    ${robot_account_name}
    Retry Element Click  xpath=//select[@id='expiration-type']
    Retry Element Click  xpath=//select[@id='expiration-type']//option[@value='never']
    Retry Double Keywords When Error    Retry Element Click    ${project_robot_account_create_save_btn}    Retry Wait Until Page Not Contains Element    ${project_robot_account_create_save_btn}
    ${token}=    Get Value    ${project_robot_account_token_input}
    [Return]    ${token}


