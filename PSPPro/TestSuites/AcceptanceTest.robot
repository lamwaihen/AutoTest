*** Settings ***
Suite Setup       Initialize
Suite Teardown    Uninitialize
Resource          ..\\Resource.robot
Resource          ..\\Keywords.robot

*** Test Cases ***
FirstLaunch32bit
    Run Keyword If    '${OS}' == '6.1'    Blind Install Build    ${BUILD}    ${LANG}    OSbits=32bit
    ...    ELSE    Install Build    ${BUILD}    ${LANG}    OSbits=32bit
    Initial Launch    ${CLASS}    ${LANG}    32bit
	
FirstLaunch64bit
    Run Keyword If    '${OS}' == '6.1'    Blind Install Build    ${BUILD}    ${LANG}    OSbits=64bit
    ...    ELSE    Install Build    ${BUILD}    ${LANG}    OSbits=64bit
    Initial Launch    ${CLASS}    ${LANG}    64bit
	
FirstLaunch64bitWithLangSwitch
    Run Keyword If    '${OS}' == '6.1'    Blind Install Build    ${BUILD}    ${LANG}    OSbits=64bit
    ...    ELSE    Install Build    ${BUILD}    ${LANG}    OSbits=64bit
    Initial Launch    ${CLASS}    ${LANG}    64bit
	${Exe}    Get Application Exe    ${CLASS}    64bit
	Switch All Languages    ${Exe}
