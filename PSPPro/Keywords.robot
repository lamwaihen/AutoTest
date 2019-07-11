*** Settings ***
Resource          Resource.robot

*** Variables ***
${currentMode}    Mode-Home

*** Keywords ***
Initialize
    [Documentation]    Initialize all necessary variables, also import the corresponding product resource file.
    ${OS} =    Get Environment Variable    version
    Set Global Variable    ${OS}
    ${LANG}    Get System Language
    Set Global Variable    ${LANG}
    Log Many    ${LOGID}    ${CLASS}    ${OPTIONS}    ${CUSTOMER}    ${VERSION}    ${VERSIONEXTENSION}    ${ALIAS}
	Import Resource    ${CURDIR}\\Resources\\${CLASS}.robot
    ${result} =    Run Keyword And Ignore Error    Should Match Regexp    ${LOGID}    ^\\d{6}$
    Set Image Horizon Library    ${LOGID}
    ${BUILD}    Set Variable If    '@{result}[0]' == 'PASS'    ${OPTIONS}_${VERSION}${VERSIONEXTENSION}_${CUSTOMER}_LOGID${LOGID}    ${LOGID}.exe
    Set Suite Variable    ${BUILD}
    ${SetupDir}    Get Setup Directory    ${CLASS}    OSbits=32bit
    Set Suite Variable    ${SetupDir}
    Hide Cmd

Install Build
    [Arguments]    ${Build}    ${Lang}=0409    ${OSbits}=64bit    # "64bit", "32bit" or "Both"
    [Documentation]    Blind test without using ImageHorizonLibrary.
    Download Build    ${Build}
    ${Exe}    Get Setup Exe
    Launch Application    ${Exe}
    Download Stub
    Sleep    10s
    Run Keyword If    ('${ALIAS}' == 'StubInstaller' and '${VERSION}' == '') or '${ALIAS}' != 'StubInstaller'    Run Keywords    Sleep    10s
	...    AND    Process Page EULA
    ...    AND    Process Page User Information
    ...    AND    Process Page Installation Options    ${OSbits}
    ...    AND    Process Page Features Settings
    ...    AND    Take Screenshot And Wait    600
    ...    AND    Process Page Install Completed
    ...    AND    Comment    Process Web Thank You for Installing
    Finish Stub
    Sleep    10s

Download Build
    [Arguments]    ${Build}    # Build package name.
    Remove Downloaded Build    ${BUILD}
    Run Keyword If    '${ALIAS}' == 'TBYB-Breakdown'    Copy Directory    ${BuildsDir}\\${CLASS}_BUILDS\\${ALIAS}\\${VERSION}\\${BUILD}    ${DownloadDir}
    ...    ELSE IF    '${ALIAS}' == 'StubInstaller' and '${VERSION}' == ''    Copy File    ${BuildsDir}\\${CLASS}_BUILDS\\${ALIAS}\\${BUILD}    ${DownloadDir}
    ...    ELSE    Copy Directory    ${BuildsDir}\\${CLASS}_BUILDS\\${ALIAS}\\${BUILD}    ${DownloadDir}

Download Stub
    [Documentation]    Process the first 2 pages of stub install.
    Run Keyword If    '${ALIAS}' != 'StubInstaller'    Take Screenshot And Wait    60
    ...    ELSE    Run Keywords    Sleep    30s
    ...    AND    Wait For    Checkbox Stub Eula    240
    ...    AND    Click Image    Checkbox Stub Eula
    ...    AND    Click Image    Button Stub Next
    ...    AND    Take Screenshot And Wait    600

Finish Stub
    Run Keyword If    '${ALIAS}' == 'StubInstaller'    Run Keywords    Wait For    Button Stub Next    240
    ...    AND    Click Image    Button Stub Next

Remove Downloaded Build
    [Arguments]    ${Build}    # Build package name.
    [Documentation]    To remove specific build package downloaded to local computer.
    ${result}    Run Keyword And Return Status    Directory Should Exist    ${DownloadDir}\\${Build}
    Run Keyword If    '${result}' == 'True'    Remove Directory    ${DownloadDir}\\${Build}    recursive=True

Uninstall Build
    [Documentation]    To uninstall the testing build.
    Directory Should Exist    ${SetupDir}    Application is not installed.
    Launch Application    "${SetupDir}\\Setup.exe"
    Wait For    Page Uninstall options    240
    Press Combination    Key.AltLeft    Key.m    # Remove
    Sleep    2m
    Wait For    Page Uninstall Completed    300

Fail and Wait
    [Documentation]    When failure, take a screenshot, wait 2 minutes then take another screenshot. This will help to check if application run too slow.
    Take A Screenshot
    Sleep    1m
    Take A Screenshot

Get Application Exe
    [Arguments]    ${Class}    ${OSbits}
    [Documentation]    Return the executable file of the application.
    ${Dir} =    Get Application Directory    ${Class}    ${OSbits}
    ${Path} =    Catenate    SEPARATOR=\\    ${Dir}    Corel PaintShop Pro.exe
    File Should Exist    ${Path}
    [Return]    ${Path}

Get Setup Directory
    [Arguments]    ${Class}    ${OSbits}
    ${Dir} =    Get Application Directory    ${Class}    ${OSbits}
    ${Dir} =    Catenate    SEPARATOR=\\    ${Dir}    Setup
    ${hasFolder}    Run Keyword And Return Status    Directory Should Exist    ${Dir}
    @{Folders}    Run Keyword If    ${hasFolder}    List Directories In Directory    ${Dir}
    ${Dir}    Run Keyword If    ${hasFolder}    Catenate    SEPARATOR=\\    ${Dir}    @{Folders}[0]
    [Return]    ${Dir}

Process Close Restart Prompt
	Take A Screenshot
	Click Varied Image    Button Restart Later
	Take A Screenshot

Process Dialog Register
    [Documentation]    Process the registration dialog.
	Comment    Process Close Restart Prompt
    Click Button    Register-Email
    Type Keyboard    ${EMAIL}
    Click Button    Register
    Sleep    5s
	Take A Screenshot
	Click Button    Register-Continue

Process Page EULA
    [Documentation]    Assume page EULA is visible, begin to process.
    Comment    Page EULA
    Sleep    30s
	Take A Screenshot
	Click Button    Setup-Accept	
	Take A Screenshot
	Click Button    Setup-Next
	
Process Page User Information
    Comment    Page User Information
    ${Serial} =    Get Serial Number
    Sleep    30s
	${isTBYB} =  Evaluate   'TBYB' in '${CUSTOMER}'
	Run Keyword If    '${isTBYB}' == 'True'    Return From Keyword
    Run Keyword If    '${Serial}' != ''    Run Keywords    Click Button    Setup-Serial
    ...    AND    Type Keyboard    ${Serial}
    ...    AND    Click Button    Setup-Next

Process Page Installation Options
    [Arguments]    ${OSbits}
    Comment    Page Installation Options
    ${is32or64} =    Run Keyword And Ignore Error    Should Contain Any    ${CUSTOMER}    X86    X64
    Sleep    30s
    Take A Screenshot
    Run Keyword If    ${is32or64} != ('PASS', None)    Run Keywords    Select Install Options    ${OSbits}
    ...    AND    Take A Screenshot
    ...    AND    Click Button    Setup-Next

Process Page Features Settings
	Comment    Page Features Settings
    Sleep    30s
    Take A Screenshot
    Run Keyword If    '${ALIAS}' != 'TBYB-Breakdown' and '${ALIAS}' != 'SoftBank'    Run Keywords    Click Button    Setup-Languages
    ...    AND    Run Keyword If    '${LANG}' == '0409'    Select All Languages
    Take A Screenshot
	Click Button    Setup-Next
	
Process Page Install Completed
    Comment    Page Install Completed
	Sleep    30s
	Click Button    Setup-CheckUpdates
	Take A Screenshot
	Click Button    Setup-Next
	
Process Web Thank You for Installing
	Comment    Web Thank You for Installing
    Sleep    30s
	Take A Screenshot
	Click Button    Browser-Close

Process Guided Tour
    [Documentation]     Switch to given mode and process its guided tour, modes are "EssentialsEdit", "CompleteEdit", "CompleteManage" and "PhotographyEdit"
    [Arguments]    ${mode}
	Run Keyword If    '${mode}' == 'EssentialsEdit'    Run Keywords    Switch Mode    Mode-EssentialsEdit
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
    ...    ELSE IF    '${mode}' == 'CompleteEdit'    Run Keywords    Switch Mode    Mode-CompleteEdit
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
    ...    ELSE IF    '${mode}' == 'CompleteManage'    Run Keywords    Switch Mode    Mode-CompleteManage
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Sleep    10s
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Sleep    10s
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
	...    AND    Take A Screenshot
    ...    AND    Click Button    GuidedTour-Next
    ...    ELSE IF    '${mode}' == 'PhotographyEdit'    Run Keywords    Switch Mode    Mode-PhotographyEdit
	...    AND    Click Button    Photography-TouchFriendly
	...    AND    Switch Mode    Mode-Home

Initial Launch
    [Arguments]    ${Class}    ${Lang}=0409    ${OSbits}=64bit
    [Documentation]    Register and launch application for the first time.
    ${is32bits} =    Run Keyword And Ignore Error    Should Contain    ${CUSTOMER}    X86
    ${bits} =    Set Variable If    ${is32bits} == ('PASS', None)    32bit    ${OSbits}
    ${Exe}    Get Application Exe    ${Class}    ${bits}
    Launch Application    '${Exe}'
    Take A Screenshot
    Sleep    90s
    Process Dialog Register
    Take A Screenshot
    Sleep    90s
    Take A Screenshot
    Sleep    90s
    Take A Screenshot
    Click Button    Welcome-GetStarted
    Sleep    30s
    Process Guided Tour    EssentialsEdit
    Process Guided Tour    CompleteEdit
    Process Guided Tour    CompleteManage
    Process Guided Tour    PhotographyEdit
    Return From Keyword
    ${pos} =    Wait For    Mode Button Home Light    240
    Click To The Above Of    ${pos}    0
    Take Screenshot And Wait For    Welcome Essentials Light    300
    Defocus
    ${pos} =    Take Screenshot And Wait For    Radio Workspaces Complete    300
    Click To The Above Of    ${pos}    0
    Move To    960    540
    Sleep    1m
    Process Guided Tour    Manage    Dark
    Sleep    30s
    Process Guided Tour    Edit    Dark
    ${pos} =    Wait For    Mode Button Home Dark    240
    Click To The Above Of    ${pos}    0
    Take Screenshot And Wait For    Welcome Essentials Dark    300
    ${pos} =    Take Screenshot And Wait For    Radio Workspaces Essentials    300
    Click To The Above Of    ${pos}    0
    Take Screenshot And Wait For    Welcome Essentials Light    300

Select All Languages
    [Documentation]    To select all language options in the tree control when installing English version.
    Press Combination    Key.Down    # Click down twice
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'Traditional Chinese'
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'German'
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'Spanish'
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'French'
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'Italian'
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'Japanese'
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'Dutch'
    Press Combination    Key.Down
    Press Combination    Key.Space    # Select 'Russian'

Select Install Options
    [Arguments]    ${OSbits}
    Run Keyword If    '${OSbits}' == '64bit'    Click Button    Setup-Option64bit
    ...    ELSE IF    '${OSbits}' == '32bit'    Click Button    Setup-Option32bit
    ...    ELSE    Click Button    Setup-OptionBoth

Select Switch Language
    [Arguments]    ${FromLang}    ${ToLang}
    ${from} =    Get Index From List    ${Languages}    ${FromLang}
    ${to} =    Get Index From List    ${Languages}    ${ToLang}
    ${moves} =    Evaluate    ${to} - ${from}
    ${step} =    Set Variable If    ${moves} < 0    -1    ${moves} >= 0    1
    : FOR    ${INDEX}    IN RANGE    0    ${moves}    ${step}
    \    Run Keyword If    ${step} == 1    Press Combination    Key.Down
    \    ...    ELSE    Press Combination    Key.Up
    Press Combination    Key.Enter
    Sleep    5s
    Does Varied Exist    Dialog Switch Language Restart
    Press Combination    Key.Enter

Switch All Languages
    [Arguments]    ${Exe}
    : FOR    ${lang}    IN    @{Languages}
    \    Switch Language    ${Exe}    ${lang}

Switch Language
    [Arguments]    ${Exe}    ${To}
    [Documentation]    Switch application GUI language
    Sleep    10s
    Click To The Below Of Image    Icon Light    32
    Press Combination    Key.Up
    Press Combination    Key.Up
    Press Combination    Key.Right
    Press Combination    Key.Up
    Press Combination    Key.Enter
    Sleep    10s
    Does Varied Exist    Dialog Switch Language
    Select Switch Language    ${LANG}    ${To}
    Click To The Below Of Image    Icon Light    32
    Press Combination    Key.Up
    Press Combination    Key.Enter
    Sleep    10s
    ${hasUpdatePrompt} =    Run Keyword And Ignore Error    Does Exist    Dialog Update Prompt
    Run Keyword If    ${hasUpdatePrompt} == ('PASS', True)    Press Shortcut Key    ${To}    Close
    Sleep    30s
    Set Suite Variable    ${LANG}    ${To}
    ImageHorizonLibrary.Set Reference Folder    ${CURDIR}\\Images\\${LANG}
    Set System Language Preferences
    Set System Fonts    ${LANG}
    Launch Application    '${Exe}'
    Wait For    Splash Screen    480
    Wait For    Welcome Essentials Light    600
    Take A Screenshot
    Process Guided Tour    Edit    Light
    Click Image    Mode Button Home Light

Switch Mode
    [Arguments]    ${mode}
    Run Keyword If    '${mode}' == 'Mode-Home'    Click Button    Mode-Home
    ...    ELSE IF    '${mode}' == 'Mode-EssentialsEdit'    Run Keywords    Click Button    Mode-Home    AND    Sleep     30s    AND    Click Button    Welcome-WorkspaceEssentials    AND    Sleep    30s    AND    Take A Screenshot    AND    Click Button    ${mode}
    ...    ELSE IF    '${mode}' == 'Mode-CompleteEdit'    Run Keywords    Click Button    Mode-Home    AND    Sleep     30s    AND    Click Button    Welcome-WorkspaceComplete    AND    Sleep    30s    AND    Take A Screenshot    AND    Click Button    ${mode}
    ...    ELSE IF    '${mode}' == 'Mode-CompleteManage'    Run Keywords    Click Button    Mode-Home    AND    Sleep     30s    AND    Click Button    Welcome-WorkspaceComplete    AND    Sleep    30s    AND    Take A Screenshot    AND    Click Button    ${mode}
	...    ELSE IF    '${mode}' == 'Mode-PhotographyEdit'    Run Keywords    Click Button    Mode-Home    AND    Sleep     30s    AND    Click Button    Welcome-WorkspacePhotography    AND    Sleep    30s    AND    Take A Screenshot    AND    Click Button    ${mode}
	Sleep    60s
	Take A Screenshot
	
Uninitialize
    Comment    Sleep    60s
    Comment    Press Combination    Key.Win    Key.r
    Comment    Type    shutdown /p /f /t 60
    Comment    Press Combination    Key.Enter

Defocus
    [Documentation]    Click somewhere outside the dialog to defocus.
    Move To    960    1
    Click
