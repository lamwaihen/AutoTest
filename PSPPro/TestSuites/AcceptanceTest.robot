*** Settings ***
Suite Setup       Initialize
Suite Teardown    Uninitialize
Resource          ..\\Resource.robot
Resource          ..\\Keywords.robot

*** Test Cases ***
FirstLaunch32bit
    Install Build    ${BUILD}    ${LANG}    OSbits=32bit
    Initial Launch    ${CLASS}    32bit
	
FirstLaunch64bit
    Install Build    ${BUILD}    ${LANG}    OSbits=64bit
    Initial Launch    ${CLASS}    64bit
