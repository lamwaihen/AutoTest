*** Settings ***
Resource          Resource.robot

*** Variables ***

*** Keywords ***
Initialize
    ${OS} =    Get Environment Variable    version
    Set Suite Variable    ${OS}
    Log Many    ${LOGID}    ${CLASS}    ${OPTIONS}    ${CUSTOMER}    ${VERSION}    ${VERSIONEXTENSION}
    ...    ${ALIAS}
    ${LANG}    Get System Language
    Set Suite Variable    ${LANG}
    ${result} =    Run Keyword And Ignore Error    Should Match Regexp    ${LOGID}    ^\\d{6}$
    Set Image Horizon Library    ${CLASS}    ${LANG}    ${LOGID}
    ${BUILD}    Set Variable If    '@{result}[0]' == 'PASS'    ${OPTIONS}_${VERSION}${VERSIONEXTENSION}_${CUSTOMER}_LOGID${LOGID}    ${LOGID}.exe
    Set Suite Variable    ${BUILD}
    ${SetupDir}    Get Setup Directory    ${CLASS}    OSbits=32bit
    Set Suite Variable    ${SetupDir}
    Hide Cmd

Blind Install Build
    [Arguments]    ${Build}    ${Lang}=0409    ${OSbits}=64bit    # "64bit", "32bit" or "Both"
    [Documentation]    For Windows 7 which we can't use ImageHorizonLibrary.
    Download Build    ${Build}
    ${Exe}    Get Setup Exe
    Launch Application    ${Exe}
    ${Serial} =    Get Serial Number
    Download Stub
    Sleep    10s
    Run Keyword If    ('${ALIAS}' == 'StubInstaller' and '${VERSION}' == '') or '${ALIAS}' != 'StubInstaller'    Run Keywords    Sleep    300
	...    AND    Blind Process Page EULA    ${CLASS}    ${Lang}
    ...    AND    Comment    Page User Information
    ...    AND    Sleep    30s
    ...    AND    Move To    454    546
    ...    AND    Click
    ...    AND    Type Keyboard    ${Lang}    ${Serial}
    ...    AND    Sleep    5s
    ...    AND    Move To    1130    845
    ...    AND    Click
    ...    AND    Comment    Page Installation Options
    ...    AND    Sleep    30s
    ...    AND    Move To    1130    845
    ...    AND    Click
    ...    AND    Comment    Page Features Settings
    ...    AND    Sleep    30s
    ...    AND    Move To    1130    845
    ...    AND    Click
    ...    AND    Comment    Page Completed
    ...    AND    Sleep    600s
    ...    AND    Move To    456    777
    ...    AND    Click
    ...    AND    Sleep    5s
    ...    AND    Move To    1130    845
    ...    AND    Click
    ...    AND    Process Web Thank You for Installing    ${Lang}
    Finish Stub
    Take Screenshot And Wait    180

Install Build
    [Arguments]    ${Build}    ${Lang}=0409    ${OSbits}=64bit    # "64bit", "32bit" or "Both"
    Download Build    ${Build}
    ${Exe}    Get Setup Exe
    Launch Application    ${Exe}
    Download Stub
    Sleep    10s
    Run Keyword If    ('${ALIAS}' == 'StubInstaller' and '${VERSION}' == '') or '${ALIAS}' != 'StubInstaller'    Run Keywords    Take Screenshot And Wait For    Page EULA    400
    ...    AND    Click Image    Page EULA
    ...    AND    Press Shortcut Key    ${Lang}    Accept
    ...    AND    Sleep    5s
    ...    AND    Press Shortcut Key    ${Lang}    Next
    ...    AND    Process Page User Information    ${Lang}
    ...    AND    Process Page Installation Options    ${OSbits}
    ...    AND    Process Page Features Settings    ${Lang}
    ...    AND    Wait For Varied    Page completed    600
    ...    AND    Run Keyword If    '${CLASS}' == 'PSPX10'    Click Varied Image    Checkbox check updates
    ...    AND    Press Shortcut Key    ${Lang}    Finish
    ...    AND    Comment    Wait For    PSPX10 Initialization    240
    ...    AND    Process Web Thank You for Installing    ${Lang}
    Finish Stub
    Take Screenshot And Wait    180

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

Get Application Directory
    [Arguments]    ${Class}    ${OSbits}
    ${Dir} =    Set Variable If    '${Class}' == 'PSPX11' and '${OSBits}'=='32bit'    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro 2019    '${Class}' == 'PSPX11' and '${OSBits}'=='64bit'    C:\\Program Files\\Corel\\Corel PaintShop Pro 2019 (64-bit)    '${Class}' == 'PSPX10' and '${OSBits}'=='32bit'    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro 2018    '${Class}' == 'PSPX10' and '${OSBits}'=='64bit'    C:\\Program Files\\Corel\\Corel PaintShop Pro 2018 (64-bit)    '${Class}' == 'PSPX9' and '${OSBits}'=='32bit'
    ...    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro X9    '${Class}' == 'PSPX9' and '${OSBits}'=='64bit'    C:\\Program Files\\Corel\\Corel PaintShop Pro X9 (64-bit)
    [Return]    ${Dir}

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

Get Setup Exe
    ${Path} =    Set Variable If
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-PF(RELEASE)'    '${DownloadDir}\\${Build}\\PSP2018_PF.exe'    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE)'    '${DownloadDir}\\${Build}\\PSP2018_Ultimate_PF.exe'    
	...    '${CUSTOMER}' == 'PHOTO(QA)-STUBINSTALLER(RELEASE-PF)'    '${DownloadDir}\\${Build}\\PSP2018Stub_PF.exe'    
	...    '${CUSTOMER}' == 'PHOTO(QA)-STUBINSTALLER(RELEASE-TBYB)'    '${DownloadDir}\\${Build}\\PSP2018Stub_TBYB.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY)'    '${DownloadDir}\\${Build}\\PSP2018_TBYB30.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-SOFTBANK)'    '${DownloadDir}\\${Build}\\PSP2018_TBYB30_SoftBank.exe'    
    ...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX64)'    '${DownloadDir}\\${Build}\\PSP2018_tw_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX86)'    '${DownloadDir}\\${Build}\\PSP2018_tw_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEx64)'    '${DownloadDir}\\${Build}\\PSP2018_de_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEX86)'    '${DownloadDir}\\${Build}\\PSP2018_de_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX64)'    '${DownloadDir}\\${Build}\\PSP2018_es_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX86)'    '${DownloadDir}\\${Build}\\PSP2018_es_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX64)'    '${DownloadDir}\\${Build}\\PSP2018_fr_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX86)'    '${DownloadDir}\\${Build}\\PSP2018_fr_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX64)'    '${DownloadDir}\\${Build}\\PSP2018_it_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX86)'    '${DownloadDir}\\${Build}\\PSP2018_it_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX64)'    '${DownloadDir}\\${Build}\\PSP2018_jp_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX86)'    '${DownloadDir}\\${Build}\\PSP2018_jp_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX64)'    '${DownloadDir}\\${Build}\\PSP2018_nl_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX86)'    '${DownloadDir}\\${Build}\\PSP2018_nl_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX64)'    '${DownloadDir}\\${Build}\\PSP2018_ru_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX86)'    '${DownloadDir}\\${Build}\\PSP2018_ru_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX64)'    '${DownloadDir}\\${Build}\\PSP2018_en_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX86)'    '${DownloadDir}\\${Build}\\PSP2018_en_32\\Setup.exe'  
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-ROYALTYFREE(RELEASE)'    '${DownloadDir}\\${Build}\\Corel_PSP2018RF.exe'
	...    '${VERSION}' == '' and '${ALIAS}' == 'StubInstaller'    '${DownloadDir}\\${Build}'
	...    '${DownloadDir}\\${Build}\\Setup.exe'
	${Path2} =    Run Keyword If    '${CLASS}' == 'PSPX11'    Replace String    ${Path}    PSP2018    PSP2019
	...    ELSE    ${Path}
    [Return]    ${Path2}

Get Serial Number
    ${isProTBYB} =  Evaluate   'PHOTOPRO(QA)-TBYB' in '${CUSTOMER}'
    ${Type} =    Set Variable If    '${CUSTOMER}' == 'PHOTOPRO(QA)-RETAIL(RELEASE)'    PSPX10_ProRetail
    ...    '${CUSTOMER}' == 'PHOTOPRO(QA)-PF(RELEASE)'    PSPX10_ProRetail 
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-PF(RELEASE-SOFTBANK)'    PSPX10_ProRetail   
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-ROYALTYFREE(RELEASE)'    PSPX10_ProRetail    
	...    '${isProTBYB}' == 'True'    PSPX10_ProTBYB
	...    '${CUSTOMER}' == 'PHOTOBASIC(QA)-RETAIL(RELEASE)'    PSPX10_BasicRetail    
	...    '${CUSTOMER}' == 'PHOTOBASIC(QA)-TBYB(RELEASE-30DAY)'    PSPX10_BasicTBYB    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-RETAIL(RELEASE)'    PSPX10_UltimateRetail    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE)'    PSPX10_UltimateRetail    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE-SOFTBANK)'    PSPX10_UltimateRetail    
	...    '${CLASS}' == 'PSPX10' and '${LOGID}' == 'PSP2018_Pro'    PSPX10_ProRetail    
	...    '${CLASS}' == 'PSPX10' and '${LOGID}' == 'PSP2018_Ult'    PSPX10_UltimateRetail    
	...    '${CLASS}' == 'PSPX11' and '${LOGID}' == 'PSP2019_Pro'    PSPX11_ProRetail    
	...    '${CLASS}' == 'PSPX11' and '${LOGID}' == 'PSP2019_Ult'    PSPX11_UltimateRetail    Fail
    ...    Unknown CUSTOMER
	${Type} =    Run Keyword If    '${CLASS}' == 'PSPX11'    Replace String    ${Type}    PSPX10    PSPX11
    ${Serial} =    Get From Dictionary    ${SerialNumbers}    ${Type}
    [Return]    ${Serial}

Process Close Restart Prompt
	Take A Screenshot
	Click Varied Image    Button Restart Later
	Take A Screenshot

Process Dialog Register
    [Arguments]    ${Lang}
	Process Close Restart Prompt	
    Sleep    20s
    Take A Screenshot
    Wait For Varied    Dialog Register    480
    Click Varied Image    Dialog Register
    Press Shortcut Key    ${Lang}    Email
    Type Keyboard    ${Lang}    ${Email}
    Click Varied Image    Button Register
    Sleep    30s
    Take A Screenshot
    Wait For Varied    Button Continue    240
    Click Varied Image    Button Continue
	
Blind Process Page EULA
    [Arguments]    ${Class}    ${Lang}=0409
	Comment    Page EULA
	Run Keyword If    '${Class}' == 'PSPX10'    Move To    456    765
	...    ELSE IF    '${Class}' == 'PSPX11' and '${Lang}' == '0411'    Move To    456    598
	...    ELSE    Move To    456    582
	Click
    Sleep    5s
    Move To    1130    845
    Click

Process Page User Information
    [Arguments]    ${Lang}
    ${Serial} =    Get Serial Number
    Sleep    10s
    Take A Screenshot
	${isTBYB} =  Evaluate   'TBYB' in '${CUSTOMER}'
	Run Keyword If    '${isTBYB}' == 'True'    Return From Keyword
    Run Keyword If    '${Serial}' != ''    Run Keywords    Wait For Varied    Page User information    240
    ...    AND    Press Shortcut Key    ${Lang}    Serial Number
    ...    AND    Type Keyboard    ${Lang}    ${Serial}
    ...    AND    Press Shortcut Key    ${Lang}    Next

Process Page Installation Options
    [Arguments]    ${OSbits}
    ${is32or64} =    Run Keyword And Ignore Error    Should Contain Any    ${CUSTOMER}    X86    X64
    Sleep    10s
    Take A Screenshot
    Run Keyword If    ${is32or64} != ('PASS', None)    Run Keywords    Wait For Varied    Page Installation options    240
    ...    AND    Select Install Options    ${OSbits}
    ...    AND    Take A Screenshot
    ...    AND    Press Shortcut Key    ${Lang}    Next

Process Page Features Settings
    [Arguments]    ${Lang}
    Sleep    10s
    Take A Screenshot
    Wait For    Page Features Settings    240
    Defocus
    Run Keyword If    '${ALIAS}' != 'TBYB-Breakdown' and '${ALIAS}' != 'SoftBank'    Run Keywords    Click Image    Checkbox languages
    ...    AND    Run Keyword If    '${Lang}' == '0409'    Select All Languages
    Click To The Below Of Image    Page Features Settings    150
    Press Shortcut Key    ${Lang}    Install Now
	
Process Web Thank You for Installing
    [Arguments]    ${Lang}
	Click Varied Image    Button Default Browser OK
    Wait For Varied    Web Thank You for Installing    480
	Click Varied Image    Web Thank You for Installing
    Press Shortcut Key    ${Lang}    Close
	Sleep    5s
	Click Varied Image    Button Browser Close All Tabs

Process Guided Tour
    [Arguments]    ${Mode}    ${Theme}
    Switch Mode    ${Mode}    ${Theme}
    ${pos} =    Run Keyword If    '${Mode}' == 'Edit' and '${Theme}' == 'Light'    Wait For    Guided Tour Edit Light 1    240
    ...    ELSE IF    '${Mode}' == 'Edit' and '${Theme}' == 'Dark'    Wait For    Guided Tour Edit Dark 1    240
    ...    ELSE IF    '${Mode}' == 'Manage' and '${Theme}' == 'Dark'    Wait For    Guided Tour Manage Dark 1    240
    Run Keyword If    '${Mode}' == 'Edit' and '${Theme}' == 'Light'    Run Keywords    Wait For    Guided Tour Edit Light 1    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Light 2    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Light 3    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Light 4    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Light 5    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    ELSE IF    '${Mode}' == 'Edit' and '${Theme}' == 'Dark'    Run Keywords    Wait For    Guided Tour Edit Dark 1    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Dark 2    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Dark 3    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Dark 4    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Edit Dark 5    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    ELSE IF    '${Mode}' == 'Manage' and '${Theme}' == 'Dark'    Run Keywords    Wait For    Guided Tour Manage Dark 1    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Manage Dark 2    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Manage Dark 3    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Manage Dark 4    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Manage Dark 5    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Manage Dark 6    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215
    ...    AND    Wait For    Guided Tour Manage Dark 7    240
    ...    AND    Sleep    5s
    ...    AND    Take A Screenshot
    ...    AND    Click To The Right Of    ${pos}    215

Initial Launch
    [Arguments]    ${Class}    ${Lang}=0409    ${OSbits}=64bit
    [Documentation]    Register and launch application for the first time.
    ${is32bits} =    Run Keyword And Ignore Error    Should Contain    ${CUSTOMER}    X86
    ${bits} =    Set Variable If    ${is32bits} == ('PASS', None)    32bit    ${OSbits}
    ${Exe}    Get Application Exe    ${Class}    ${bits}
    Launch Application    '${Exe}'
    Process Dialog Register    ${Lang}
    Comment    Sleep    10s
    Take A Screenshot
    Run Keyword If    '${CLASS}' != 'PSPX10'    Take Screenshot And Wait    60
	...    ELSE    Take Screenshot And Wait For    Splash Screen    480
	Run Keyword If    '${CLASS}' != 'PSPX10'    Run Keywords    Wait For Varied    Welcome Start    600
	...    AND    Click Varied Image    Welcome Start
    Take Screenshot And Wait For    Welcome Essentials Light    600
    Process Guided Tour    Edit    Light
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
    Run Keyword If    '${OSbits}' == '64bit'    Click Varied Image    Install Option 64bit
    ...    ELSE IF    '${OSbits}' == '32bit'    Click Varied Image    Install Option 32bit
    ...    ELSE    Click Varied Image    Install Option both

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
    Sleep    5s
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
    [Arguments]    ${Mode}    ${Theme}
    Run Keyword If    '${Mode}' == 'Home' and '${Theme}' == 'Light'    Click Image    Mode Button Home Light
    ...    ELSE IF    '${Mode}' == 'Home' and '${Theme}' == 'Dark'    Click Image    Mode Button Home Dark
    ...    ELSE IF    '${Mode}' == 'Manage' and '${Theme}' == 'Light'    Click Image    Mode Button Manage Light
    ...    ELSE IF    '${Mode}' == 'Manage' and '${Theme}' == 'Dark'    Click Image    Mode Button Manage Dark
    ...    ELSE IF    '${Mode}' == 'Edit' and '${Theme}' == 'Light'    Click Image    Mode Button Edit Light
    ...    ELSE IF    '${Mode}' == 'Edit' and '${Theme}' == 'Dark'    Click Image    Mode Button Edit Dark

Switch Workspace
    [Arguments]    ${Workspace}

Uninitialize
    Comment    Sleep    60s
    Comment    Press Combination    Key.Win    Key.r
    Comment    Type    shutdown /p /f /t 60
    Comment    Press Combination    Key.Enter

Defocus
    [Documentation]    Click somewhere outside the dialog to defocus.
    Move To    960    1
    Click
