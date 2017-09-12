*** Settings ***
Suite Setup       Initialize
Resource          ..\\Resource.robot
Resource          ..\\Keywords.robot

*** Variables ***

*** Test Cases ***
Install
    [Documentation]    testing
    Install Build    ${BUILD}    OSbits=64bit

Test
    Log    ${LANG}
    Click Image    Install option 32bit
    Comment    Run Keyword If    '${ProductSKU}' == 'Ultimate'    Run Keyword    Log    message=Ultimate
    ...    ELSE    Log 'Other'

Uninstall
    Log    ${SetupDir}
    Uninstall Build
