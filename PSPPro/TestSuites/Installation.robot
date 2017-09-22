*** Settings ***
Suite Setup       Initialize
Suite Teardown    Uninitialize
Resource          ..\\Resource.robot
Resource          ..\\Keywords.robot

*** Variables ***

*** Test Cases ***
Install32bit
    [Documentation]    testing
    Install Build    ${BUILD}    ${LANG}    OSbits=32bit

Install64bit
    [Documentation]    testing
    Install Build    ${BUILD}    ${LANG}    OSbits=64bit

InstallBoth
    [Documentation]    testing
    Install Build    ${BUILD}    ${LANG}    OSbits=Both

Test
    Log    ${LANG}
    Click Image    Install option 32bit
    Comment    Run Keyword If    '${ProductSKU}' == 'Ultimate'    Run Keyword    Log    message=Ultimate
    ...    ELSE    Log 'Other'

Uninstall
    Log    ${SetupDir}
    Uninstall Build
