*** Settings ***
Suite Setup       Initialize
Resource          ..\\Resource.robot
Resource          ..\\Keywords.robot

*** Variables ***

*** Test Cases ***
Install
    [Documentation]    testing
    Install Build    OSbits=32bit

Test
    Log    ${CurrentLang}
    Comment    Initialize
    Comment    Run Keyword If    '${ProductSKU}' == 'Ultimate'    Run Keyword    Log    message=Ultimate
    ...    ELSE    Log 'Other'

Uninstall
    Log     ${SetupDir}
    Uninstall Build
