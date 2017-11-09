*** Settings ***
Resource          Resource.robot
Library           OperatingSystem
Library           Collections
Library           String
Library           winregistry.robot    # Library to read registry.
Library           ImageHorizonLibrary    screenshot_folder=output    keyword_on_failure=Fail and Wait

*** Variables ***

*** Keywords ***
Install Build
    [Arguments]    ${Build}    ${Lang}=0409    ${OSbits}=64bit    # "64bit", "32bit" or "Both"
    [Timeout]    20min
    Download Build    ${Build}
    ${Exe}    Get Setup Exe
    Launch Application    ${Exe}
    Wait For    Page EULA    6000
    Press Combination    Key.Alt    Key.a    # Select 'I accept the terms...'
    Press Combination    Key.Alt    Key.n    # Click 'Next'
    Process Page User Information
    Process Page Installation Options    ${OSbits}
    Process Page Features Settings    ${Lang}
    Sleep    2m    # Sleep 2m while installing
    Wait For    Page completed    600
    Click Image    Checkbox check updates
    Press Combination    Key.Alt    Key.f    # Click 'Finish'
    Comment    Wait For    PSPX10 Initialization    240
    Sleep    1m
    Wait For    Web Thank You for Installing    480
    Click Image    Web Thank You for Installing
    Press Combination    Key.Alt    Key.F4    # Close browser
	Sleep    30s

Download Build
    [Arguments]    ${Build}    # Build package name.
    Remove Downloaded Build    ${BUILD}
    Run Keyword If    '${ALIAS}' == 'TBYB-Breakdown'    Copy Directory    ${BuildsDir}\\${CLASS}_BUILDS\\${ALIAS}\\${VERSION}\\${BUILD}    ${DownloadDir}
    ...    ELSE    Copy Directory    ${BuildsDir}\\${CLASS}_BUILDS\\${ALIAS}\\${BUILD}    ${DownloadDir}

Initialize
    Log Many    ${LOGID}    ${CLASS}    ${OPTIONS}    ${CUSTOMER}    ${VERSION}    ${VERSIONEXTENSION}
    ...    ${ALIAS}
    ${LANG}    Get System Language
    Set Suite Variable    ${LANG}
    ImageHorizonLibrary.Set Reference Folder    ${CURDIR}\\Images\\${LANG}
    ImageHorizonLibrary.Set Screenshot Folder    ${CURDIR}\\..\\..\\${LOGID}
    ${BUILD}    Set Variable    ${OPTIONS}_${VERSION}${VERSIONEXTENSION}_${CUSTOMER}_LOGID${LOGID}
    Set Suite Variable    ${BUILD}
    ${SetupDir}    Get Setup Directory    ${CLASS}    OSbits=32bit
    Set Suite Variable    ${SetupDir}
    Hide Cmd	

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
    Press Combination    Key.Alt    Key.m    # Remove
    Sleep    2m
    Wait For    Page Uninstall Completed    300

Fail and Wait
    [Documentation]    When failure, take a screenshot, wait 2 minutes then take another screenshot. This will help to check if application run too slow.
    Take A Screenshot
    Sleep    1m
    Take A Screenshot
	
Hide Cmd
    [Documentation]    Try to hide the command prompt window to avoid overlapping other dialogs.	
	:FOR    ${INDEX}    IN RANGE    0    10
	\    Click Image    Icon Command Prompt
	\    Sleep    2s	
	\    ${status}    Run Keyword And Return Status    Wait For    Command Prompt Context    30
	\    Run Keyword If    '${status}' == 'True'    Exit For Loop	
	Click Image    Command Prompt Context

Get Application Directory
    [Arguments]    ${Class}    ${OSbits}
    ${Dir} =    Set Variable If    '${Class}' == 'PSPX10' and '${OSBits}'=='32bit'    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro 2018    '${Class}' == 'PSPX10' and '${OSBits}'=='64bit'    C:\\Program Files\\Corel\\Corel PaintShop Pro 2018 (64-bit)    '${Class}' == 'PSPX9' and '${OSBits}'=='32bit'
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
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY)'    '${DownloadDir}\\${Build}\\PSP2018_TBYB30.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-SOFTBANK)'    '${DownloadDir}\\${Build}\\PSP2018_TBYB30_SoftBank.exe'    
    ...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX64)'    '${DownloadDir}\\${Build}\\psp2018_tw_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX86)'    '${DownloadDir}\\${Build}\\psp2018_tw_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEx64)'    '${DownloadDir}\\${Build}\\psp2018_de_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEX86)'    '${DownloadDir}\\${Build}\\psp2018_de_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX64)'    '${DownloadDir}\\${Build}\\psp2018_es_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX86)'    '${DownloadDir}\\${Build}\\psp2018_es_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX64)'    '${DownloadDir}\\${Build}\\psp2018_fr_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX86)'    '${DownloadDir}\\${Build}\\psp2018_fr_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX64)'    '${DownloadDir}\\${Build}\\psp2018_it_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX86)'    '${DownloadDir}\\${Build}\\psp2018_it_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX64)'    '${DownloadDir}\\${Build}\\psp2018_jp_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX86)'    '${DownloadDir}\\${Build}\\psp2018_jp_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX64)'    '${DownloadDir}\\${Build}\\psp2018_nl_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX86)'    '${DownloadDir}\\${Build}\\psp2018_nl_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX64)'    '${DownloadDir}\\${Build}\\psp2018_ru_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX86)'    '${DownloadDir}\\${Build}\\psp2018_ru_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX64)'    '${DownloadDir}\\${Build}\\psp2018_en_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX86)'    '${DownloadDir}\\${Build}\\psp2018_en_32\\Setup.exe'  
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-ROYALTYFREE(RELEASE)'    '${DownloadDir}\\${Build}\\Corel_PSP2018RF.exe'
	...    '${DownloadDir}\\${Build}\\Setup.exe'
    [Return]    ${Path}

Get Serial Number
    ${Type} =    Set Variable If    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-RETAIL(RELEASE)'    ProRetail
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-PF(RELEASE)'    ProRetail
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-ROYALTYFREE(RELEASE)'    ProRetail
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-SOFTBANK)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-SOFTBANK-X64)'    ProTBYB
    ...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX64)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX86)'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOBASIC(QA)-RETAIL(RELEASE)'    BasicRetail
	...    '${CUSTOMER}' == 'PHOTOBASIC(QA)-TBYB(RELEASE-30DAY)'    BasicTBYB
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-RETAIL(RELEASE)'    UltimateRetail
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE)'    UltimateRetail
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE-SOFTBANK)'    UltimateRetail
	...    Fail    Unknown CUSTOMER
	${Serial} =    Get From Dictionary    ${SerialNumbers}    ${Type}
    [Return]    ${Serial}

Get System Language
    # Get the current language from registry
    &{lang}    Read Registry Value    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\Language    InstallLanguage
    ${sysLang}    Set Variable    &{lang}[data]
    [Return]    ${sysLang}
	
Launch Onscreen Keyboard
    [Documentation]    Run osk.exe and manually move it to bottom of screen.
	Run Keyword If    '${Lang}' != '0411'    Return from Keyword
	Press Combination    Key.Win    Key.R
	Type    osk.exe
	Press Combination    Key.Enter
	Wait For    Icon Onscreen Keyboard    240
	Click Image    Icon Onscreen Keyboard
	Press Combination    Key.Alt    Key.Space    Key.M
	:FOR    ${INDEX}    IN RANGE    0    50
	\    Press Combination    Key.Down
	Press Combination    Key.Enter
	
Process Dialog Register
    Wait For    Dialog Register    480
	Launch Onscreen Keyboard
	Click Image    Dialog Register
	Press Combination    Key.Alt    Key.E
	Type Onscreen Keyboard    ${Email}
    Click Image    Button Register
	Sleep    30s
    Wait For    Button Continue    240
	Take A Screenshot
    Click Image    Button Continue

Process Page User Information
    ${Serial} =    Get Serial Number
    Run Keyword If    '${Serial}' != ''    Run Keywords    Wait For    Page User information    240
    ...    AND    Press Combination    Key.Alt    Key.s
    ...    AND    Type    ${Serial}
    ...    AND    Press Combination    Key.Alt    Key.n    # Select 'Serial Number'    # Click 'Next'

Process Page Installation Options
    [Arguments]    ${OSbits}	
	${is32or64} =    Run Keyword And Ignore Error    Should Contain Any    ${CUSTOMER}    X86    X64
	Run Keyword If    ${is32or64} != ('PASS', None)
    ...    Run Keywords    Wait For    Page Installation options    240
    ...    AND    Select Install Options    ${OSbits}
    ...    AND    Take A Screenshot
    ...    AND    Press Combination    Key.Alt    Key.n    # Click 'Next'

Process Page Features Settings
    [Arguments]    ${Lang}
    Wait For    Page Features Settings    240
    Defocus
    Run Keyword If    '${ALIAS}' != 'TBYB-Breakdown' and '${ALIAS}' != 'SoftBank'    Run Keywords    Click Image    Checkbox languages
    ...    AND    Run Keyword If    '${Lang}' == '0409'    Select All Languages
    Click Image    Page Features Settings
    Press Combination    Key.Alt    Key.i    # Click 'Install Now'

Process Guided Tour
    [Arguments]    ${Mode}    ${Theme}
    Switch Mode    ${Mode}    ${Theme}
    Run Keyword If    '${Mode}' == 'Edit' and '${Theme}' == 'Light'    Run Keywords    Wait For    Guided Tour Edit Light 1    240
    ...    AND    Click To The Right Of Image    Guided Tour Edit Light 1    215
    ...    AND    Wait For    Guided Tour Edit Light 2    240
    ...    AND    Click To The Right Of Image    Guided Tour Edit Light 2    215
    ...    AND    Wait For    Guided Tour Edit Light 3    240
    ...    AND    Click To The Right Of Image    Guided Tour Edit Light 3    215
    ...    AND    Wait For    Guided Tour Edit Light 4    240
    ...    AND    Click To The Right Of Image    Guided Tour Edit Light 4    215
    ...    AND    Wait For    Guided Tour Edit Light 5    240
    ...    AND    Click To The Right Of Image    Guided Tour Edit Light 5    215
    ...    ELSE IF    '${Mode}' == 'Edit' and '${Theme}' == 'Dark'    Run Keywords    Wait For    Guided Tour Edit Dark 1    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Edit Dark 2    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Edit Dark 3    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Edit Dark 4    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Edit Dark 5    240
    ...    AND    Click Image    Guided Tour Button Finish Dark
    ...    ELSE IF    '${Mode}' == 'Manage' and '${Theme}' == 'Dark'    Run Keywords    Wait For    Guided Tour Manage Dark 1    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Manage Dark 2    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Manage Dark 3    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Manage Dark 4    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Manage Dark 5    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Manage Dark 6    240
    ...    AND    Click Image    Guided Tour Button Next Dark
    ...    AND    Wait For    Guided Tour Manage Dark 7    240
    ...    AND    Click Image    Guided Tour Button Finish Dark

Initial Launch
    [Arguments]    ${Class}    ${OSbits}=64bit
    [Documentation]    Register and launch application for the first time.
	${is32bits} =    Run Keyword And Ignore Error    Should Contain    ${CUSTOMER}    X86
    ${bits} =    Set Variable If    ${is32bits} == ('PASS', None)    32bit    ${OSbits}
    ${Exe}    Get Application Exe    ${Class}    ${bits}
    Launch Application    '${Exe}'
    Process Dialog Register
    Wait For    Splash Screen    480
    Wait For    Welcome Essentials Light    600
    Process Guided Tour    Edit    Light
    Click Image    Mode Button Home Light
    Wait For    Welcome Essentials Light    240
	Defocus
    Click Image    Radio Workspaces Complete
	Move To    960    540
	Sleep    1m
    Process Guided Tour    Manage    Dark
	Sleep    30s
    Process Guided Tour    Edit    Dark
    Click Image    Mode Button Home Dark
    Wait For    Welcome Essentials Dark    240
    Click Image    Radio Workspaces Essentials
    Wait For    Welcome Essentials Light    240
	Run Keyword If    '${Lang}' == '0409'    Run Keywords    Switch Language    ${Exe}    0404
	...    AND    Switch Language    ${Exe}    0C0A
	...    AND    Switch Language    ${Exe}    040C
	...    AND    Switch Language    ${Exe}    0404
	...    AND    Switch Language    ${Exe}    0407
	...    AND    Switch Language    ${Exe}    0410
	...    AND    Switch Language    ${Exe}    0411
	...    AND    Switch Language    ${Exe}    0413
	...    AND    Switch Language    ${Exe}    0419

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
    Run Keyword If    '${OSbits}' == '64bit'    Click Image    Install Option 64bit
    ...    ELSE IF    '${OSbits}' == '32bit'    Click Image    Install Option 32bit
    ...    ELSE    Click Image    Install Option both
	
Select Switch Language
    [Arguments]    ${FromLang}    ${ToLang}
	${from} =    Get Index From List    ${Languages}    ${FromLang}
	${to} =    Get Index From List    ${Languages}    ${ToLang}
	${moves} =    Evaluate    ${to} - ${from}
	${step} =    Set Variable If    ${moves} < 0    -1
	...    ${moves} >= 0    1
	:FOR    ${INDEX}    IN RANGE    0    ${moves}    ${step}
	\    Run Keyword If    ${step} == 1    Press Combination    Key.Down
	\    ...    ELSE    Press Combination    Key.Up
	Press Combination    Key.Enter
	Wait For    Dialog Switch Language Restart    240
	Press Combination    Key.Enter	
	
Set System Fonts
    [Arguments]    ${Lang}
	${regFontSubstitutes} =    Set Variable    HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes
	${regSystemLink} =    Set Variable    HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\FontLink\\SystemLink
	@{twSysLinkSegoeUI} =    Create List
	...    TAHOMA.TTF,Tahoma
    ...    MSJH.TTC,Microsoft Jhenghei UI,128,96
    ...    MSJH.TTC,Microsoft Jhenghei UI
    ...    MSYH.TTC,Microsoft YaHei UI,128,96
    ...    MSYH.TTC,Microsoft YaHei UI
    ...    MEIRYO.TTC,Meiryo UI,128,96
    ...    MEIRYO.TTC,Meiryo UI
    ...    MINGLIU.TTC,PMingLiU
    ...    SIMSUN.TTC,SimSun
    ...    MSGOTHIC.TTC,MS UI Gothic
    ...    MALGUN.TTF,Malgun Gothic,128,96
    ...    MALGUN.TTF,Malgun Gothic
    ...    GULIM.TTC,Gulim
    ...    YUGOTHM.TTC,Yu Gothic UI,128,96
    ...    YUGOTHM.TTC,Yu Gothic UI
    ...    SEGUISYM.TTF,Segoe UI Symbol
	@{enSysLinkSegoeUI} =    Create List
	...    TAHOMA.TTF,Tahoma
	...    MEIRYO.TTC,Meiryo UI,128,96
	...    MEIRYO.TTC,Meiryo UI
	...    MSGOTHIC.TTC,MS UI Gothic
	...    MSJH.TTC,Microsoft JhengHei UI,128,96
	...    MSJH.TTC,Microsoft JhengHei UI
	...    MSYH.TTC,Microsoft YaHei UI,128,96
	...    MSYH.TTC,Microsoft YaHei UI
	...    MALGUN.TTF,Malgun Gothic,128,96
	...    MALGUN.TTF,Malgun Gothic
	...    MINGLIU.TTC,PMingLiU
	...    SIMSUN.TTC,SimSun
	...    GULIM.TTC,Gulim
	...    YUGOTHM.TTC,Yu Gothic UI,128,96
	...    YUGOTHM.TTC,Yu Gothic UI
	Run Keyword If    '${LANG}' == '0404'    Write Registry Value    ${regSystemLink}    Segoe UI    ${twSysLinkSegoeUI}    REG_MULTI_SZ
	...    ELSE    Run Keyword And Ignore Error    Write Registry Value    ${regSystemLink}    Segoe UI    ${enSysLinkSegoeUI}    REG_MULTI_SZ

Set System Language Preferences
	[Documentation]    Open Control Panel/Language window to adjust other, which display Japanese correctly on English system
	Press Combination    Key.Win    Key.R
	Type    control /name Microsoft.Language
	Press Combination    Key.Enter
	Sleep    5s
	Click Image    Button UILanguage
	:FOR    ${INDEX}    IN RANGE    0    8
	\    Run Keyword And Ignore Error    Click Image    Button MoveUp
	\    Sleep    2s
	\    Click Image    Button UILanguage
	\    ${canMoveUp} =    Run Keyword And Ignore Error    Does Exist    Button MoveUp
	\    Run Keyword If    ${canMoveUp} != ('PASS', True)    Exit For Loop	
    Press Combination    Key.Alt    Key.F4	
	
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
	Wait For    Dialog Switch Language    240
	Select Switch Language    ${LANG}    ${To}
	Click To The Below Of Image    Icon Light    32
	Press Combination    Key.Up
	Press Combination    Key.Enter
	Sleep    10s
	${hasUpdatePrompt} =    Run Keyword And Ignore Error    Does Exist    Dialog Update Prompt
    Run Keyword If    ${hasUpdatePrompt} == ('PASS', True)    Press Combination    Key.Alt    Key.F4
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
	
Type Onscreen Keyboard
    [Documentation]    Helper function to type onscreen keyboard in Japanese OS, close after completed.
    [Arguments]    ${Input}
	Run Keyword If    '${Lang}' != '0411'    Run Keywords    Type    ${Input}
	...    AND    Return from Keyword
	${length} =    Get Length    ${Input}
	@{characters} =	   Split String To Characters    ${Input}
	:FOR    ${char}    IN     @{characters}
    \    Run Keyword If    '${char}' == 'a'    Click Image    OSK a
	\    ...    ELSE IF    '${char}' == 'b'    Click Image    OSK b
	\    ...    ELSE IF    '${char}' == 'c'    Click Image    OSK c
	\    ...    ELSE IF    '${char}' == 'd'    Click Image    OSK d
	\    ...    ELSE IF    '${char}' == 'e'    Click Image    OSK e
	\    ...    ELSE IF    '${char}' == 'i'    Click Image    OSK i
	\    ...    ELSE IF    '${char}' == 'l'    Click Image    OSK l
	\    ...    ELSE IF    '${char}' == 'm'    Click Image    OSK m
	\    ...    ELSE IF    '${char}' == 'o'    Click Image    OSK o
	\    ...    ELSE IF    '${char}' == 'r'    Click Image    OSK r
	\    ...    ELSE IF    '${char}' == 's'    Click Image    OSK s
	\    ...    ELSE IF    '${char}' == 'u'    Click Image    OSK u
	\    ...    ELSE IF    '${char}' == '@'    Click Image    OSK at
	\    ...    ELSE IF    '${char}' == '.'    Click Image    OSK dot
	Click Image    Icon Onscreen Keyboard
	:FOR    ${INDEX}    IN RANGE    0    6
	\    Press Combination    Key.Down
	Press Combination    Key.Enter

Uninitialize
    Comment    Sleep    60s
    Comment    Press Combination    Key.Win    Key.r
    Comment    Type    shutdown /p /f /t 60
    Comment    Press Combination    Key.Enter

Defocus
    [Documentation]    Click somewhere outside the dialog to defocus.
    Move To    960    1
    Click
