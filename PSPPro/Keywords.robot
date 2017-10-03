*** Settings ***
Resource          Resource.robot
Library           OperatingSystem
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
    Wait For    PSPX10 Initialization    240
    Sleep    1m
    Wait For    Web Thank You for Installing    240
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
    ImageHorizonLibrary.SetReferenceFolder    ${CURDIR}\\Images\\${LANG}
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
    Sleep    2m
    Take A Screenshot
	
Hide Cmd
    ${cmd} =    Wait For    Icon Command Prompt
	Move To    ${cmd}
	Click    right
	Press Combination    Key.Down
	Press Combination    Key.Down
	Press Combination    Key.Down
	Press Combination    Key.Down
	Press Combination    Key.Enter

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
    ${Path} =    Set Variable If    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-TWx64)'    '${DownloadDir}\\${Build}\\psp2018_tw_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-TWx86)'    '${DownloadDir}\\${Build}\\psp2018_tw_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-DEx64)'
    ...    '${DownloadDir}\\${Build}\\psp2018_de_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-DEx86)'    '${DownloadDir}\\${Build}\\psp2018_de_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-ESx64)'    '${DownloadDir}\\${Build}\\psp2018_es_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-ESx86)'
    ...    '${DownloadDir}\\${Build}\\psp2018_es_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-FRx64)'    '${DownloadDir}\\${Build}\\psp2018_fr_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-FRx86)'    '${DownloadDir}\\${Build}\\psp2018_fr_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-ITx64)'
    ...    '${DownloadDir}\\${Build}\\psp2018_it_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-ITx86)'    '${DownloadDir}\\${Build}\\psp2018_it_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-JPx64)'    '${DownloadDir}\\${Build}\\psp2018_jp_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-JPx86)'
    ...    '${DownloadDir}\\${Build}\\psp2018_jp_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-NLx64)'    '${DownloadDir}\\${Build}\\psp2018_nl_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-NLx86)'    '${DownloadDir}\\${Build}\\psp2018_nl_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-RUx64)'
    ...    '${DownloadDir}\\${Build}\\psp2018_ru_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-RUx86)'    '${DownloadDir}\\${Build}\\psp2018_ru_32\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-ENx64)'    '${DownloadDir}\\${Build}\\psp2018_en_64\\Setup.exe'    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-ENx86)'
    ...    '${DownloadDir}\\${Build}\\psp2018_en_32\\Setup.exe'    '${DownloadDir}\\${Build}\\Setup.exe'
    [Return]    ${Path}

Get System Language
    # Get the current language from registry
    &{lang}    Read Registry Value    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\Language    InstallLanguage
    ${sysLang}    Set Variable    &{lang}[data]
    [Return]    ${sysLang}

Process Dialog Register
    Wait For    Dialog Register    480
    Press Combination    Key.Alt    Key.e
    Type    ${Email}
    Click Image    Button Register
    Wait For    Dialog Registration Completed    240
    Click Image    Button Continue

Process Page User Information
    Run Keyword If    '${ALIAS}' == 'Ultimate'    Run Keywords    Wait For    Page User information    240
    ...    AND    Press Combination    Key.Alt    Key.s
    ...    AND    Type    ${SerialUltimateRetail}
    ...    AND    Press Combination    Key.Alt    Key.n    # Select 'Serial Number'    # Click 'Next'

Process Page Installation Options
    [Arguments]    ${OSbits}
    Run Keyword If    '${ALIAS}' == 'Ultimate'    Run Keywords    Wait For    Page Installation options    240
    ...    AND    Select Install Options    ${OSbits}
    ...    AND    Take A Screenshot
    ...    AND    Press Combination    Key.Alt    Key.n    # Click 'Next'

Process Page Features Settings
    [Arguments]    ${Lang}
    Wait For    Page Features Settings    240
    Defocus
    Run Keyword If    '${ALIAS}' == 'Ultimate'    Run Keywords    Click Image    Checkbox languages
    ...    AND    Run Keyword If    '${Lang}' == '0409'    Select All Languages
    Click Image    Page Features Settings
    Press Combination    Key.Alt    Key.i    # Click 'Install Now'

Process Guided Tour
    [Arguments]    ${Mode}    ${Theme}
    Switch Mode    ${Mode}    ${Theme}
    Run Keyword If    '${Mode}' == 'Edit' and '${Theme}' == 'Light'    Run Keywords    Wait For    Guided Tour Edit Light 1    240
    ...    AND    Click Image    Guided Tour Button Next Light
    ...    AND    Wait For    Guided Tour Edit Light 2    240
    ...    AND    Click Image    Guided Tour Button Next Light
    ...    AND    Wait For    Guided Tour Edit Light 3    240
    ...    AND    Click Image    Guided Tour Button Next Light
    ...    AND    Wait For    Guided Tour Edit Light 4    240
    ...    AND    Click Image    Guided Tour Button Next Light
    ...    AND    Wait For    Guided Tour Edit Light 5    240
    ...    AND    Click Image    Guided Tour Button Finish Light
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
    ${bits} =    Set Variable If    '${ALIAS}' == 'TBYB-Breakdown'    64bit    ${OSbits}
    ${Exe}    Get Application Exe    ${Class}    ${bits}
    Launch Application    '${Exe}'
    Process Dialog Register
    Wait For    Splash Screen    240
    Wait For    Welcome Essentials Light    240
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

Switch Language
    [Arguments]    ${From}    ${To}
    [Documentation]    Switch application GUI language

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
    Move To    1    1
    Click
