*** Settings ***
Documentation     A resouce file for PSPX12.
Library           String
Library           ImageHorizonLibrary    screenshot_folder=output    keyword_on_failure=Fail and Wait

*** Variables ***
&{SerialNumbers}    ProRetail=TS22R22-7FQEMDJ-DMD3USD-9QHSX4W
    ...    ProTBYB=TS22T22-NMYCL5T-PYHFPN8-UG628ZQ
	...    ProVLP=
	...    BasicRetail=
	...    BasicTBYB=
    ...    UltimateRetail=TU22R22-CFP7PJ3-38ERDLE-5UEA7JG
    ...    UltimateTBYB=TU22T22-GXV5QBK-X84HY63-3D29XKL

*** Keywords ***
Get Application Directory
    [Arguments]    ${Class}    ${OSbits}
    ${Dir} =    Set Variable If    '${OSBits}'=='32bit'    C:\\Program Files (x86)\\Corel\\Corel PaintShop Pro 2020
    ...    '${OSBits}'=='64bit'    C:\\Program Files\\Corel\\Corel PaintShop Pro 2020 (64-bit)
    [Return]    ${Dir}

Get Browser-Close Pos
	@{pos}    Run Keyword If    '${LANG}' == '0407'    Create List    1792    68
	...    ELSE    Create List    1225    48
    [Return]    ${pos}

Get GuidedTour-Next Pos
	@{pos} =    Create List    1166    656
    [Return]    ${pos}
	
Get Modes Pos
    [Arguments]    ${modeName}
    @{pos}    Run Keyword If    '${modeName}' == 'Mode-Home'    Create List    876    26
    ...    ELSE IF    '${modeName}' == 'Mode-EssentialsEdit' or '${modeName}' == 'Mode-CompleteManage' or '${modeName}' == 'Mode-PhotographyEdit'    Create List    960    26
    ...    ELSE IF    '${modeName}' == 'Mode-CompleteEdit'    Create List    1068    26
	[Return]    ${pos}

Get Photography-TouchFriendly Pos
	@{pos} =    Create List    1110    624
    [Return]    ${pos}
	
Get Register Pos
    [Documentation]    Location of the register button on register dialog.
	@{pos} =    Run Keyword If    '${LANG}' == '0404'    Create List    724    598
	...    ELSE IF    '${LANG}' == '0407'    Create List    736    570
	...    ELSE IF    '${LANG}' == '040C'    Create List    736    640
	...    ELSE IF    '${LANG}' == '0411'    Create List    724    640
	...    ELSE IF    '${LANG}' == '0413'    Create List    736    640
	...    ELSE IF    '${LANG}' == '0419'    Create List    736    640
	...    ELSE IF    '${LANG}' == '0C0A'    Create List    736    640
	...    ELSE    Create List    736    618
    [Return]    ${pos}

Get Register-Continue Pos
    [Documentation]    Location of the continue button on register dialog.
	@{pos} =    Create List    1230    735
    [Return]    ${pos}

Get Register-Email Pos
    [Documentation]    Location of the email editbox on register dialog.
	@{pos} =    Run Keyword If    '${LANG}' == '0404'    Create List    690    466
	...    ELSE IF    '${LANG}' == '0407'    Create List    690    504
	...    ELSE    Create List    690    486
    [Return]    ${pos}

Get Serial Number
    ${isProTBYB} =  Evaluate   'PHOTOPRO(QA)-TBYB' in '${CUSTOMER}'
    ${Type} =    Set Variable If    '${CUSTOMER}' == 'PHOTOPRO(QA)-RETAIL(RELEASE)'    ProRetail
    ...    '${CUSTOMER}' == 'PHOTOPRO(QA)-PF(RELEASE)'    ProRetail 
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-PF(RELEASE-SOFTBANK)'    ProRetail   
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-ROYALTYFREE(RELEASE)'    ProRetail    
	...    '${isProTBYB}' == 'True'    ProTBYB
	...    '${CUSTOMER}' == 'PHOTOBASIC(QA)-RETAIL(RELEASE)'    BasicRetail    
	...    '${CUSTOMER}' == 'PHOTOBASIC(QA)-TBYB(RELEASE-30DAY)'    BasicTBYB    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-RETAIL(RELEASE)'    UltimateRetail    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE)'    UltimateRetail    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE-SOFTBANK)'    UltimateRetail    
	...    '${LOGID}' == 'PSP2020_Pro'    ProRetail    
	...    '${LOGID}' == 'PSP2020_Ult'    UltimateRetail
    ...    Fail    Unknown CUSTOMER
    ${Serial} =    Get From Dictionary    ${SerialNumbers}    ${Type}
    [Return]    ${Serial}

Get Setup Exe
    ${Path} =    Set Variable If
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-RETAIL(RELEASE)'    '${DownloadDir}\\${Build}\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-PF(RELEASE)'    '${DownloadDir}\\${Build}\\PSP2020_PF.exe'    
	...    '${CUSTOMER}' == 'PHOTOULT(QA)-PF(RELEASE)'    '${DownloadDir}\\${Build}\\PSP2020_Ultimate_PF.exe'    
	...    '${CUSTOMER}' == 'PHOTO(QA)-STUBINSTALLER(RELEASE-PF)'    '${DownloadDir}\\${Build}\\PSP2020Stub_PF.exe'    
	...    '${CUSTOMER}' == 'PHOTO(QA)-STUBINSTALLER(RELEASE-TBYB)'    '${DownloadDir}\\${Build}\\PSP2020Stub_TBYB.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY)'    '${DownloadDir}\\${Build}\\PSP2020_TBYB30.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-SOFTBANK)'    '${DownloadDir}\\${Build}\\PSP2020_TBYB30_SoftBank.exe'    
    ...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX64)'    '${DownloadDir}\\${Build}\\psp2020_tw_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-TWX86)'    '${DownloadDir}\\${Build}\\psp2020_tw_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEx64)'    '${DownloadDir}\\${Build}\\psp2020_de_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-DEX86)'    '${DownloadDir}\\${Build}\\psp2020_de_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX64)'    '${DownloadDir}\\${Build}\\psp2020_es_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ESX86)'    '${DownloadDir}\\${Build}\\psp2020_es_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX64)'    '${DownloadDir}\\${Build}\\psp2020_fr_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-FRX86)'    '${DownloadDir}\\${Build}\\psp2020_fr_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX64)'    '${DownloadDir}\\${Build}\\psp2020_it_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ITX86)'    '${DownloadDir}\\${Build}\\psp2020_it_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX64)'    '${DownloadDir}\\${Build}\\psp2020_jp_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-JPX86)'    '${DownloadDir}\\${Build}\\psp2020_jp_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX64)'    '${DownloadDir}\\${Build}\\psp2020_nl_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-NLX86)'    '${DownloadDir}\\${Build}\\psp2020_nl_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX64)'    '${DownloadDir}\\${Build}\\psp2020_ru_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-RUX86)'    '${DownloadDir}\\${Build}\\psp2020_ru_32\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX64)'    '${DownloadDir}\\${Build}\\psp2020_en_64\\Setup.exe'    
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-TBYB(RELEASE-30DAY-ENX86)'    '${DownloadDir}\\${Build}\\psp2020_en_32\\Setup.exe'  
	...    '${CUSTOMER}' == 'PHOTOPRO(QA)-ROYALTYFREE(RELEASE)'    '${DownloadDir}\\${Build}\\Corel_PSP2020RF.exe'
	...    '${VERSION}' == '' and '${ALIAS}' == 'StubInstaller'    '${DownloadDir}\\${Build}'
	...    '${DownloadDir}\\${Build}\\Setup.exe'
    [Return]    ${Path}
	
Get Setup-Accept Pos
    [Documentation]    Location of the accept checkbox on Setup's EULA page.
	@{pos}    Run Keyword If    '${OS}' == '6.1' and '${LANG}' == '0411'    Create List    456    598
	...    ELSE IF    '${OS}' == '6.1'    Create List    456    582
	...    ELSE IF    '${LANG}' == '0411'    Create List    616    538
	...    ELSE    Create List    616    524
	[Return]    ${pos}

Get Setup-CheckUpdates Pos
	@{pos} =    Create List    616    717
    [Return]    ${pos}
	
Get Setup-Languages Pos
	@{pos} =    Create List    652    426
    [Return]    ${pos}
	
Get Setup-Next Pos
    @{pos}    Run Keyword If    '${OS}' == '6.1'    Create List    1130    845
    ...    ELSE    Create List    1274    786
	[Return]    ${pos}
	
Get Setup-Options Pos
    [Arguments]    ${optionName}
    @{pos}    Run Keyword If    '${optionName}' == 'Setup-OptionBoth' and '${LANG}' == '0411'    Create List    666    429
    ...    ELSE IF    '${optionName}' == 'Setup-OptionBoth'    Create List    666    425
	...    ELSE IF    '${optionName}' == 'Setup-Option64bit' and '${LANG}' == '0411'    Create List    666    548
    ...    ELSE IF    '${optionName}' == 'Setup-Option64bit'    Create List    666    531
	...    ELSE IF    '${optionName}' == 'Setup-Option32bit' and '${LANG}' == '0411'    Create List    666    667
	...    ELSE IF    '${optionName}' == 'Setup-Option32bit'    Create List    666    637
	[Return]    ${pos}
	
Get Setup-Serial Pos
	@{pos}    Run Keyword If    '${LANG}' == '0411'    Create List    616    496
	...    ELSE    Create List    616    486
    [Return]    ${pos}
	
Get Welcome-GetStarted Pos
	@{pos} =    Run Keyword If    '${LANG}' == '0404'    Create List    502    160
	...    ELSE IF    '${LANG}' == '0411'    Create List    502    154
	...    ELSE    Create List    502    180
    [Return]    ${pos}
	
Get Welcome-Workspaces Pos
    [Documentation]    Location of the workspace radio buttons.
    [Arguments]    ${workspaceName}
    @{pos}    Run Keyword If    '${workspaceName}' == 'Welcome-WorkspacePhotography' and '${LANG}' == '0404'    Create List    1030    200
	...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspacePhotography' and '${LANG}' == '0411'    Create List    1030    200
    ...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspacePhotography'    Create List    1030    226
	...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspaceEssentials' and '${LANG}' == '0404'    Create List    1030    225
	...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspaceEssentials' and '${LANG}' == '0411'    Create List    1030    225
	...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspaceEssentials' and '${LANG}' == '0419'    Create List    1030    273
    ...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspaceEssentials'    Create List    1030    250
    ...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspaceComplete' and '${LANG}' == '0404'    Create List    1030    250
    ...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspaceComplete' and '${LANG}' == '0411'    Create List    1030    250
    ...    ELSE IF    '${workspaceName}' == 'Welcome-WorkspaceComplete'    Create List    1030    274
	[Return]    ${pos}