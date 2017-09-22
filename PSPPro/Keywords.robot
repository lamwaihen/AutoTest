*** Settings ***
Resource          Resource.robot
Library           OperatingSystem
Library           winregistry.robot    # Library to read registry.

*** Variables ***

*** Keywords ***
Install Build
    [Arguments]    ${Build}    ${Lang}=0409    ${OSbits}=64bit    # "64bit", "32bit" or "Both"
	[Timeout]    20min
    Download Build    ${Build}
    Log    ${DownloadDir}\\${Build}\\Setup.exe
    Launch Application    "${DownloadDir}\\${Build}\\Setup.exe"
    Wait For    Page EULA    120
    Press Combination    Key.Alt    Key.a    # Select 'I accept the terms...'
    Press Combination    Key.Alt    Key.n    # Click 'Next'
    Wait For    Page User information    120
    Press Combination    Key.Alt    Key.s    # Select 'Serial Number'
    Type    ${SerialUltimateRetail}
    Press Combination    Key.Alt    Key.n    # Click 'Next'
    Wait For    Page Installation options    120
    Run Keyword If    '${OSbits}' == '64bit'    Click Image    Install Option 64bit
    ...    ELSE IF    '${OSbits}' == '32bit'    Click Image    Install Option 32bit
    ...    ELSE    Click Image    Install Option both
    Press Combination    Key.Alt    Key.n    # Click 'Next'
	Defocus
    Wait For    Page Features Settings
	Click Image    Checkbox languages
    Run Keyword If    '${Lang}' == '0409'    Select All Languages
	Click Image    Page Features settings
    Press Combination    Key.Alt    Key.i    # Click 'Install Now'
    Sleep    2m    # Sleep 2m while installing
    Wait For    Page completed    600
    Click Image    Checkbox check updates
    Press Combination    Key.Alt    Key.f    # Click 'Finish'
    Wait For    PSPX10 Initialization    120

Download Build
    [Arguments]    ${Build}    # Build package name.
    Remove Downloaded Build    ${BUILD}
    Copy Directory    ${BuildsDir}\\${CLASS}_BUILDS\\${ALIAS}\\${BUILD}    ${DownloadDir}

Initialize
    Log Many    ${LOGID}    ${CLASS}    ${OPTIONS}    ${CUSTOMER}    ${VERSION}    ${VERSIONEXTENSION}
    ...    ${ALIAS}
    ${LANG}    Get System Language
    Set Suite Variable    ${LANG}
    ImageHorizonLibrary.SetReferenceFolder    ${CURDIR}\\Images\\${LANG}
    ImageHorizonLibrary.Set Screenshot Folder    ${CURDIR}\\Output\\${LANG}
    ${BUILD}    Set Variable    ${OPTIONS}_${VERSION}${VERSIONEXTENSION}_${CUSTOMER}_LOGID${LOGID}
    Set Suite Variable    ${BUILD}
    ${SetupDir}    Get Setup Directory    ${CLASS}
    Set Suite Variable    ${SetupDir}

Remove Downloaded Build
    [Arguments]    ${Build}    # Build package name.
    [Documentation]    To remove specific build package downloaded to local computer.
    ${result}    Run Keyword And Return Status    Directory Should Exist    ${DownloadDir}\\${Build}
    Run Keyword If    '${result}' == 'True'    Remove Directory    ${DownloadDir}\\${Build}    recursive=True

Uninstall Build
    [Documentation]    To uninstall the testing build.
    Directory Should Exist    ${SetupDir}    Application is not installed.
    Launch Application    "${SetupDir}\\Setup.exe"
    Wait For    Page Uninstall options    120
    Press Combination    Key.Alt    Key.m    # Remove
    Sleep    2m
    Wait For    Page Uninstall Completed    300

Get Setup Directory
    [Arguments]    ${Class}
    ${Dir}    Run Keyword If    '${Class}' == 'PSPX10'    Set Variable    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro 2018\\Setup
    ...    ELSE IF    '${Class}' == 'PSPX9''    Set Variable    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro X9\\Setup
    ${hasFolder}    Run Keyword And Return Status    Directory Should Exist    ${Dir}
    @{Folders}    Run Keyword If    ${hasFolder}    List Directories In Directory    ${Dir}
    ${Dir}    Run Keyword If    ${hasFolder}    Catenate    SEPARATOR=\\    ${Dir}    @{Folders}[0]
    [Return]    ${Dir}

Get System Language
    # Get the current language from registry
    &{lang}    Read Registry Value    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\Language    InstallLanguage
    ${sysLang}    Set Variable    &{lang}[data]
    [Return]    ${sysLang}

Initial Launch
    [Arguments]    ${OSbits}=64bit
    [Documentation]    Register and launch application for the first time.

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

Uninitialize
    Comment    Sleep    60s
    Comment    Press Combination    Key.Win    Key.r 
    Comment    Type    shutdown /p /f /t 60
    Comment    Press Combination    Key.Enter

Defocus
	Move To    1    1
	Click