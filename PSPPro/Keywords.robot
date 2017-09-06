*** Settings ***
Resource          Resource.robot

*** Variables ***

*** Keywords ***
Install Build
    [Arguments]    ${OSbits}=64bit    ${Lang}=en-US    # "64bit", "32bit" or "Both"
    Log    ${DownloadDir}\\${BuildName}\\Setup.exe
    Launch Application    "${DownloadDir}\\${BuildName}\\Setup.exe"
    WaitFor    Page EULA    120
    ClickImage    Checkbox Accept license agreement
    PressCombination    Key.Alt    Key.n
    ${imgLocation}    WaitFor    Page user information    60
    PressCombination    Key.Alt    Key.s
    Type    ${SerialUltimateRetail}
    PressCombination    Key.Alt    Key.n
    WaitFor    Page install option    60
    Run Keyword If    '${OSbits}' == '64bit'    ClickImage    Install Option 64bit
    ...    ELSE IF    '${OSbits}' == '32bit'    Click Image    Install Option 32bit
    ...    ELSE    Click Image    Install Option both
    PressCombination    Key.Alt    Key.n
    ${imgLocation}    WaitFor    Button install now
    ClickImage    Button install now
    Sleep    2m
    WaitFor    Page completed    600
    ClickImage    Checkbox check updates
    ClickImage    Button finish
    Wait For    PSPX10 Initialization    120

Download Build
    Remove Downloaded Build    ${BuildName}
    CopyDirectory    ${BuildsDir}\\${ProductName}\\${ProductSKU}\\${BuildName}    ${DownloadDir}

Initialize
    ImageHorizonLibrary.SetReferenceFolder    ${CURDIR}\\Images\\${CurrentLang}
    ImageHorizonLibrary.Set Screenshot Folder    ${CURDIR}\\Output\\${CurrentLang}
    ${SetupDir}    Get Setup Directory    ${ProductName}
    Set Suite Variable    ${SetupDir}
    Comment    Download Build

Remove Downloaded Build
    [Arguments]    ${Build}    # Build package name.
    [Documentation]    To remove specific build package downloaded to local computer.
    ${result}    Run Keyword And Return Status    Directory Should Exist    ${DownloadDir}\\${Build}
    Run Keyword If    '${result}' == 'True'    Remove Directory    ${DownloadDir}\\${Build}    recursive=True

Uninstall Build
    [Documentation]    To uninstall the testing build.
    Log    ${SetupDir}
    Launch Application    "${SetupDir}\\Setup.exe"
    Wait For    Page Uninstall options    120
    Press Combination    Key.Alt    Key.m    # Remove
    Sleep    2m
    Wait For    Page Uninstall Completed    300

Get Setup Directory
    [Arguments]    ${Product}
    ${Dir}    Run Keyword If    '${Product}' == 'PSPX10_BUILDS'    Set Variable    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro 2018\\Setup
    ...    ELSE IF    '${Product}' == 'PSPX9_BUILDS'    Set Variable    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro X9\\Setup
    @{Folders}    List Directories In Directory    ${Dir}
    ${Dir}    Catenate    SEPARATOR=\\    ${Dir}    @{Folders}[0]
    [Return]    ${Dir}
