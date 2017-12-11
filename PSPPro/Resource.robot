*** Settings ***
Documentation     A resouce file with reusable keywords and variables.
...
...               Use ImageHorizonLibrary for image recognized automation.
Library           DateTime
Library           OperatingSystem
Library           Collections
Library           String
Library           winregistry.robot    # Library to read registry.
Library           ImageHorizonLibrary    screenshot_folder=output    keyword_on_failure=Fail and Wait

*** Variables ***
${DownloadDir}    C:\\Users\\ivibuild\\Downloads
${BuildsDir}      \\\\corelcorp.corel.ics\\rd\\builds
&{SerialNumbers}    ProRetail=TS20R22-4EQLFW7-QNC5EVN-HTM2UW6
    ...    ProTBYB=
	...    ProVLP=TS20C22-A7X3V43-DAMUHWT-ZWZ9RSQ
	...    BasicRetail=TB20R22-NBTK8WM-NJLVNZH-8DVAJRU
	...    BasicTBYB=TB20T22-4MUX7PW-B3BGDBJ-XYMEQM2
    ...    UltimateRetail=TU20R22-9GR4R5S-KKVRD2G-MC6YNDJ
${Email}          buildrelease@corel.com
@{Languages} =    0404    0407    0409    0C0A    040C    0410    0411    0413    0419
${en-US}          0409
${zh-TW}          0404
${de-DE}          0407
${es-ES}          0C0A
${fr-FR}          040C
${it-IT}          0410
${ja-JP}          0411
${nl-NL}          0413
${ru-RU}          0419
${OS}             10.0
${LANG}           0409    #The language subfolder we store images for recognize
${SetupDir}       ${EMPTY}
${LOGID}          \    # Arguments from BM2.
${CLASS}          \    # Arguments from BM2.
${OPTIONS}        \    # Arguments from BM2.
${CUSTOMER}       \    # Arguments from BM2, e.g. "PhotoUlt(QA)-Retail(Release)"
${VERSIONEXTENSION}    \    # Arguments from BM2, e.g. "b"
${ALIAS}          \    # Arguments from BM2, e.g. "Ultimate"
${VERSION}        \    # Arguments from BM2, e.g. "20.0.0.132"
${BUILD}          \    # Build package name like "Main-Branch_20.0.0.132_PhotoUlt(QA)-Retail(Release)_LOGID563524"

*** Keywords ***
Click Varied Image
    [Arguments]    ${ImageName}
	:FOR    ${INDEX}    IN RANGE    1    6
	\    ${variedName} =    Catenate    ${ImageName}    ${INDEX}
	\    ${hasImage} =    Run Keyword And Ignore Error    Does Exist    ${variedName}
	\    Run Keyword If    ${hasImage} == ('PASS', True)    Run Keywords    Click Image    ${variedName}    AND    Exit For Loop
	
Get System Language
    # Get the current language from registry
    &{lang}    Read Registry Value    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\Language    InstallLanguage
    ${sysLang}    Set Variable    &{lang}[data]	
    [Return]    ${sysLang}

Hide Cmd
    [Documentation]    Try to hide the command prompt window to avoid overlapping other dialogs.
	${img} =    Set Variable If    '${OS}' != '6.1'    Icon Command Prompt    Icon Command Prompt Win7
	Click Image    ${img}
	Sleep    2s
	Press Combination    Key.Down
	Press Combination    Key.Down
	Press Combination    Key.Down
	Press Combination    Key.Down
	Press Combination    Key.Enter
	
Launch Onscreen Keyboard
    [Documentation]    Run osk.exe and manually move it to bottom of screen.
	Comment    Keyword If    '${Lang}' != '0411'    Return from Keyword
	Press Combination    Key.Win    Key.R
	Type    osk.exe
	Press Combination    Key.Enter
	Wait For    Icon Onscreen Keyboard    240
	Click Image    Icon Onscreen Keyboard
	Press Combination    Key.AltLeft    Key.Space    Key.M
	:FOR    ${INDEX}    IN RANGE    0    50
	\    Press Combination    Key.Down
	Press Combination    Key.Enter
	
Press Shortcut Key
    [Documentation]    Maps keyboard shortcut key for different languages
	[Arguments]    ${Lang}    ${Shortcut}
	Run Keyword If    '${Lang}' == '0407' and '${Shortcut}' == 'Accept'    Press Combination    Key.AltLeft    Key.I
	...    ELSE IF    '${Lang}' == '040C' and '${Shortcut}' == 'Accept'    Press Combination    Key.AltLeft    Key.C
	...    ELSE IF    '${Lang}' == '0410' and '${Shortcut}' == 'Accept'    Press Combination    Key.AltLeft    Key.S
	...    ELSE IF    '${Lang}' == '0413' and '${Shortcut}' == 'Accept'    Press Combination    Key.AltLeft    Key.K
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Accept'    Click Image    Checkbox Accept EULA
	...    ELSE IF    '${Shortcut}' == 'Accept'    Press Combination    Key.AltLeft    Key.A
	...    ELSE IF    '${Shortcut}' == 'Close'    Press Combination    Key.AltLeft    Key.F4
	...    ELSE IF    '${Lang}' == '040C' and '${Shortcut}' == 'Email'    Press Combination    Key.Tab
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Email'    Click To The Below Of Image    Editbox Email    24
	...    ELSE IF    '${Lang}' == '0C0A' and '${Shortcut}' == 'Email'    Press Combination    Key.AltLeft    Key.C
	...    ELSE IF    '${Shortcut}' == 'Email'    Press Combination    Key.AltLeft    Key.E
	...    ELSE IF    '${Lang}' == '0407' and '${Shortcut}' == 'Finish'    Press Combination    Key.AltLeft    Key.B
	...    ELSE IF    '${Lang}' == '040C' and '${Shortcut}' == 'Finish'    Press Combination    Key.AltLeft    Key.T
	...    ELSE IF    '${Lang}' == '0413' and '${Shortcut}' == 'Finish'    Press Combination    Key.AltLeft    Key.V
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Finish'    Click Image    Button Finish
	...    ELSE IF    '${Shortcut}' == 'Finish'    Press Combination    Key.AltLeft    Key.F
    ...    ELSE IF    '${Lang}' == '0407' and '${Shortcut}' == 'Install Now'    Press Combination    Key.AltLeft    Key.J
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Install Now'    Click Varied Image    Button Install Now
	...    ELSE IF    '${Shortcut}' == 'Install Now'    Press Combination    Key.AltLeft    Key.I
	...    ELSE IF    '${Lang}' == '0407' and '${Shortcut}' == 'Next'    Press Combination    Key.AltLeft    Key.W	
	...    ELSE IF    '${Lang}' == '040C' and '${Shortcut}' == 'Next'    Press Combination    Key.AltLeft    Key.S
	...    ELSE IF    '${Lang}' == '0410' and '${Shortcut}' == 'Next'    Press Combination    Key.AltLeft    Key.C
	...    ELSE IF    '${Lang}' == '0413' and '${Shortcut}' == 'Next'    Press Combination    Key.AltLeft    Key.V
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Next'    Click Varied Image    Button Next
	...    ELSE IF    '${Lang}' == '0C0A' and '${Shortcut}' == 'Next'    Press Combination    Key.AltLeft    Key.S
	...    ELSE IF    '${Shortcut}' == 'Next'    Press Combination    Key.AltLeft    Key.N
	...    ELSE IF    '${Lang}' == '040C' and '${Shortcut}' == 'Serial Number'    Press Combination    Key.AltLeft    Key.M
	...    ELSE IF    '${Lang}' == '0410' and '${Shortcut}' == 'Serial Number'    Press Combination    Key.AltLeft    Key.N
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Serial Number'    Click To The Below Of Image    Editbox Serial Number    24
	...    ELSE IF    '${Lang}' == '0C0A' and '${Shortcut}' == 'Serial Number'    Press Combination    Key.AltLeft    Key.M	
	...    ELSE IF    '${Shortcut}' == 'Serial Number'    Press Combination    Key.AltLeft    Key.S
	...    ELSE    Fail    Unknown shortcut key
	
Set Image Horizon Library
    [Arguments]    ${Lang}    ${LogID}
	${date} =    Get Current Date    UTC    8h    %Y-%m-%d
	${stubfolder} =    Catenate    SEPARATOR=\\    PSPX10_StubInstaller    ${date}
	${result} =    Run Keyword And Ignore Error    Should Match Regexp    ${LOGID}    ^\\d{6}$
	${folder} =    Set Variable If    '@{result}[0]' == 'PASS'    ${LogID}    ${stubfolder}	
	${result} =    Run Keyword And Return Status    List Should Contain Value    ${Languages}    ${Lang}
	${imgLang} =    Set Variable If    '${result}' == 'True'    ${Lang}    0409
    ImageHorizonLibrary.Set Reference Folder    ${CURDIR}\\Images\\${imgLang}
    ImageHorizonLibrary.Set Screenshot Folder    ${CURDIR}\\..\\..\\${folder}
	
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
    Press Combination    Key.AltLeft    Key.F4		
	
Take Screenshot And Wait
    [Documentation]    Take the amount of screenshots while waiting, so that we can monitor the process.
	[Arguments]    ${Amount}    
	:FOR    ${INDEX}    IN RANGE    0    ${Amount}
	\    Take A Screenshot
	\    Sleep    1m
	
Type Keyboard
    [Arguments]    ${Lang}    ${Input}
	@{characters} =	   Split String To Characters    ${Input}
    Take A Screenshot
	:FOR    ${char}    IN     @{characters}
    \    Run Keyword If    '${char}' == 'a'    Press Combination    Key.A
	\    ...    ELSE IF    '${char}' == 'b'    Press Combination    Key.B
	\    ...    ELSE IF    '${char}' == 'c'    Press Combination    Key.C
	\    ...    ELSE IF    '${char}' == 'C'    Press Combination    Key.ShiftLeft    Key.C
	\    ...    ELSE IF    '${char}' == 'd'    Press Combination    Key.D
	\    ...    ELSE IF    '${char}' == 'D'    Press Combination    Key.ShiftLeft    Key.D
	\    ...    ELSE IF    '${char}' == 'e'    Press Combination    Key.E
	\    ...    ELSE IF    '${char}' == 'G'    Press Combination    Key.ShiftLeft    Key.G
	\    ...    ELSE IF    '${char}' == 'i'    Press Combination    Key.I
	\    ...    ELSE IF    '${char}' == 'J'    Press Combination    Key.ShiftLeft    Key.J
	\    ...    ELSE IF    '${char}' == 'K'    Press Combination    Key.ShiftLeft    Key.K
	\    ...    ELSE IF    '${char}' == 'l'    Press Combination    Key.L
	\    ...    ELSE IF    '${char}' == 'm'    Press Combination    Key.M
	\    ...    ELSE IF    '${char}' == 'M'    Press Combination    Key.ShiftLeft    Key.M
	\    ...    ELSE IF    '${char}' == 'N'    Press Combination    Key.ShiftLeft    Key.N
	\    ...    ELSE IF    '${char}' == 'o'    Press Combination    Key.O
	\    ...    ELSE IF    '${char}' == 'r'    Press Combination    Key.R
	\    ...    ELSE IF    '${char}' == 'R'    Press Combination    Key.ShiftLeft    Key.R
	\    ...    ELSE IF    '${char}' == 's'    Press Combination    Key.S
	\    ...    ELSE IF    '${char}' == 'S'    Press Combination    Key.ShiftLeft    Key.S
	\    ...    ELSE IF    '${char}' == 'T'    Press Combination    Key.ShiftLeft    Key.T
	\    ...    ELSE IF    '${char}' == 'u'    Press Combination    Key.U
	\    ...    ELSE IF    '${char}' == 'U'    Press Combination    Key.ShiftLeft    Key.U
	\    ...    ELSE IF    '${char}' == 'V'    Press Combination    Key.ShiftLeft    Key.V
	\    ...    ELSE IF    '${char}' == 'Y'    Press Combination    Key.ShiftLeft    Key.Y
	\    ...    ELSE IF    '${char}' == '0'    Press Combination    Key.0
	\    ...    ELSE IF    '${char}' == '2'    Press Combination    Key.2
	\    ...    ELSE IF    '${char}' == '4'    Press Combination    Key.4
	\    ...    ELSE IF    '${char}' == '5'    Press Combination    Key.5
	\    ...    ELSE IF    '${char}' == '6'    Press Combination    Key.6
	\    ...    ELSE IF    '${char}' == '9'    Press Combination    Key.9
	\    ...    ELSE IF    '${Lang}' == '0407' and '${char}' == '@'    Press Combination    Key.AltRight    Key.Q
	\    ...    ELSE IF    '${Lang}' == '040C' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0410' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0411' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0413' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0419' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0C0A' and '${char}' == '@'    Press Combination    Key.AltRight    Key.2
	\    ...    ELSE IF    '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${char}' == '.'    Press Combination    Key..
	\    ...    ELSE IF    '${char}' == '-'    Press Combination    Key.-
	
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