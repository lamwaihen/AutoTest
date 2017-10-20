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
    ${Serial} =    Get From Dictionary    ${SerialNumbers}    BasicTBYB
    Log    ${Serial}

Uninstall
    Log    ${SetupDir}
    Uninstall Build
