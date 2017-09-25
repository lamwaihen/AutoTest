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
    Wait For    PSPX10 Initialization    120

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
    ${Dir} =    Set Variable If
    ...    '${Class}' == 'PSPX10'    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro 2018\\Setup
    ...    '${Class}' == 'PSPX9'    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro X9\\Setup
    ${hasFolder}    Run Keyword And Return Status    Directory Should Exist    ${Dir}
    @{Folders}    Run Keyword If    ${hasFolder}    List Directories In Directory    ${Dir}
    ${Dir}    Run Keyword If    ${hasFolder}    Catenate    SEPARATOR=\\    ${Dir}    @{Folders}[0]
    [Return]    ${Dir}
	
Get Setup Exe
	${Path} =    Set Variable If    
	...    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-JPx64)'    '${DownloadDir}\\${Build}\\psp2018_jp_64\\Setup.exe' 
	...    '${CUSTOMER}' == 'PhotoPro(QA)-TBYB(Release-30Day-ENx64)'    '${DownloadDir}\\${Build}\\psp2018_en_64\\Setup.exe'    '${DownloadDir}\\${Build}\\Setup.exe'
	[Return]    ${Path}

Get System Language
    # Get the current language from registry
    &{lang}    Read Registry Value    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\Language    InstallLanguage
    ${sysLang}    Set Variable    &{lang}[data]
    [Return]    ${sysLang}
	
Process Page User Information
    Run Keyword If    '${ALIAS}' == 'Ultimate'    Run Keywords
	...    Wait For    Page User information    120
	...    AND    Press Combination    Key.Alt    Key.s    # Select 'Serial Number'
    ...    AND    Type    ${SerialUltimateRetail}
    ...    AND    Press Combination    Key.Alt    Key.n    # Click 'Next'
	
Process Page Installation Options
    [Arguments]    ${OSbits}
    Run Keyword If    '${ALIAS}' == 'Ultimate'    Run Keywords
	...    Wait For    Page Installation options    120
    ...    AND    Select Install Options    ${OSbits}
    ...    AND    Press Combination    Key.Alt    Key.n    # Click 'Next'
	
Process Page Features Settings
    [Arguments]    ${Lang}
    Defocus
    Wait For    Page Features Settings
	Run Keyword If    '${ALIAS}' == 'Ultimate'    Run Keywords
	...    Click Image    Checkbox languages
    ...    AND    Run Keyword If    '${Lang}' == '0409'    Select All Languages
	Click Image    Page Features settings
    Press Combination    Key.Alt    Key.i    # Click 'Install Now'
	
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
	
Select Install Options 
	[Arguments]    ${OSbits}
	Run Keyword If    '${OSbits}' == '64bit'    Click Image    Install Option 64bit
    ...    ELSE IF    '${OSbits}' == '32bit'    Click Image    Install Option 32bit
    ...    ELSE    Click Image    Install Option both

Uninitialize
    Comment    Sleep    60s
    Comment    Press Combination    Key.Win    Key.r 
    Comment    Type    shutdown /p /f /t 60
    Comment    Press Combination    Key.Enter

Defocus
	Move To    1    1
	Click