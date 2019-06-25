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
&{SerialNumbers}    PSPX10_ProRetail=TS20R22-4EQLFW7-QNC5EVN-HTM2UW6
    ...    PSPX10_ProTBYB=
	...    PSPX10_ProVLP=TS20C22-A7X3V43-DAMUHWT-ZWZ9RSQ
	...    PSPX10_BasicRetail=TB20R22-NBTK8WM-NJLVNZH-8DVAJRU
	...    PSPX10_BasicTBYB=TB20T22-4MUX7PW-B3BGDBJ-XYMEQM2
    ...    PSPX10_UltimateRetail=TU20R22-9GR4R5S-KKVRD2G-MC6YNDJ
    ...    PSPX11_ProRetail=TS21R22-D5Q4KR6-VBQNFM9-DJXXGWS
    ...    PSPX11_ProTBYB=TS21T22-G8RF9WF-CLP5H3C-YWUAF5N
    ...    PSPX11_UltimateRetail=TU21R22-MMG5QWZ-LQQPXWV-CG57GKA
    ...    PSPX11_UltimateTBYB=TU21T22-ZZ9H64Q-M7THC2T-MD8WRW8
    ...    PSPX11_BasicRetail=TB21R22-RG44AJL-TML5787-7DX6768
    ...    PSPX11_BasicTBYB=TB21T22-ZA7WD5G-T5TJ42A-J7EYT38	
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
    [Arguments]    ${reference_image}
	:FOR    ${INDEX}    IN RANGE    1    6
	\    Take A Screenshot	
	\    ${variedName} =    Catenate    ${reference_image}    ${INDEX}
	\    ${hasImage} =    Run Keyword And Ignore Error    Does Exist    ${variedName}
	\    Run Keyword If    ${hasImage} == ('PASS', True)    Run Keywords    Click Image    ${variedName}    AND    Exit For Loop
	
Click To The Below Of Varied Image
    [Arguments]    ${reference_image}    ${offset}
	:FOR    ${INDEX}    IN RANGE    1    6
	\    ${variedName} =    Catenate    ${reference_image}    ${INDEX}
	\    ${hasImage} =    Run Keyword And Ignore Error    Does Exist    ${variedName}
	\    Run Keyword If    ${hasImage} == ('PASS', True)    Run Keywords    Click To The Below Of Image    ${variedName}    ${offset}    AND    Exit For Loop
	
Does Varied Exist
    [Documentation]    To get varied images and check if one exist
	[Arguments]    ${reference_image}
	${result} =    Create List    FAIL    ${EMPTY}
	Take A Screenshot
	:FOR    ${INDEX}    IN RANGE    1    6
	\    ${variedName} =    Catenate    ${reference_image}    ${INDEX}
	\    ${hasImage} =    Run Keyword And Ignore Error    Does Exist    ${variedName}
	\    ${result} =    Run Keyword If    ${hasImage} == ('PASS', True)    Create List    PASS    ${variedName}
	\    ...    ELSE    Create List    FAIL    ${EMPTY}
	\    Run Keyword If    ${hasImage} == ('PASS', True)    Exit For Loop
	[Return]    ${result}
	
Get System Language
    # Get the current language from registry
    &{lang}    Read Registry Value    HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\Language    InstallLanguage
    ${sysLang}    Set Variable    &{lang}[data]	
    [Return]    ${sysLang}

Hide Cmd
    [Documentation]    Try to hide the command prompt window to avoid overlapping other dialogs.
	Click Image    Icon Command Prompt
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
	Run Keyword If    '${Lang}' == '0419' and '${Shortcut}' == 'Accept'    Click Image    Checkbox Accept EULA
	...    ELSE IF    '${Shortcut}' == 'Accept'    Press Combination    Key.AltLeft    Key.A
	...    ELSE IF    '${Shortcut}' == 'Close'    Press Combination    Key.AltLeft    Key.F4
	...    ELSE IF    '${Lang}' == '040C' and '${Shortcut}' == 'Email'    Run Keywords    Press Combination    Key.Tab    AND    Press Combination    Key.Tab
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Email'    Click To The Below Of Varied Image    Editbox Email    24
	...    ELSE IF    '${Lang}' == '0C0A' and '${Shortcut}' == 'Email'    Press Combination    Key.AltLeft    Key.C
	...    ELSE IF    '${Shortcut}' == 'Email'    Press Combination    Key.AltLeft    Key.E
	...    ELSE IF    '${Lang}' == '0407' and '${Shortcut}' == 'Finish'    Press Combination    Key.AltLeft    Key.B
	...    ELSE IF    '${Lang}' == '040C' and '${Shortcut}' == 'Finish'    Press Combination    Key.AltLeft    Key.T
	...    ELSE IF    '${Lang}' == '0413' and '${Shortcut}' == 'Finish'    Press Combination    Key.AltLeft    Key.V
	...    ELSE IF    '${Lang}' == '0419' and '${Shortcut}' == 'Finish'    Click Varied Image    Button Finish
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
    [Arguments]    ${Class}    ${Lang}    ${LogID}
	${date} =    Get Current Date    UTC    8h    %Y-%m-%d
	${stubfolder} =    Catenate    SEPARATOR=\\    PSPX10_StubInstaller    ${date}
	${result} =    Run Keyword And Ignore Error    Should Match Regexp    ${LOGID}    ^\\d{6}$
	${folder} =    Set Variable If    '@{result}[0]' == 'PASS'    ${LogID}    ${stubfolder}	
	${result} =    Run Keyword And Return Status    List Should Contain Value    ${Languages}    ${Lang}
	${imgLang} =    Set Variable If    '${result}' == 'True'    ${Lang}    0409
	${imgLang} =    Run Keyword If    '${OS}' == '6.1'    Catenate    ${imgLang}    Win7
	...   ELSE IF    '${OS}' == '6.3'    Catenate    ${imgLang}    Win8
	...   ELSE    Catenate    ${imgLang}    Win10
	${imgFolder} =    Catenate    ${Class}    ${imgLang}
    ImageHorizonLibrary.Set Reference Folder    ${CURDIR}\\Images\\${imgFolder}
    ImageHorizonLibrary.Set Screenshot Folder    ${CURDIR}\\..\\..\\_${folder}
	
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
	[Arguments]    ${time}
	${count} =    Evaluate    ${time} / 20
    :FOR    ${INDEX}    IN RANGE    0    ${count}
	\    Take A Screenshot
	\    Sleep    20s
	
Take Screenshot And Wait For
    [Documentation]    Take the amount of screenshots while waiting for specific image, so that we can monitor the process.
	[Arguments]    ${reference_image}    ${timeout}
    Take A Screenshot
	${result} =    Create List    ${0}    ${0}
	${count} =    Evaluate    ${timeout} / 20
    :FOR    ${INDEX}    IN RANGE    0    ${count}
	\    Take A Screenshot	
	\    ${hasImage} =    Run Keyword And Ignore Error    Does Exist    ${reference_image}
	\    ${result} =    Run Keyword If    ${hasImage} == ('PASS', True)    Locate    ${reference_image}
	\    ...    ELSE    Create List    ${0}    ${0}
	\    Run Keyword If    ${hasImage} == ('PASS', True)    Exit For Loop	
	\    Sleep    20s	
	Run Keyword If    (@{result}[0] == ${0} and @{result}[1] == ${0})    Fail
	[Return]    ${result}
	
Type Keyboard
    [Arguments]    ${Lang}    ${Input}
	@{characters} =	   Split String To Characters    ${Input}
    Take A Screenshot
	:FOR    ${char}    IN     @{characters}
    \    Run Keyword If    '${char}' == 'a'    Press Combination    Key.A
	\    ...    ELSE IF    '${char}' == 'A'    Press Combination    Key.ShiftLeft    Key.A
	\    ...    ELSE IF    '${char}' == 'b'    Press Combination    Key.B
	\    ...    ELSE IF    '${char}' == 'B'    Press Combination    Key.ShiftLeft    Key.B
	\    ...    ELSE IF    '${char}' == 'c'    Press Combination    Key.C
	\    ...    ELSE IF    '${char}' == 'C'    Press Combination    Key.ShiftLeft    Key.C
	\    ...    ELSE IF    '${char}' == 'd'    Press Combination    Key.D
	\    ...    ELSE IF    '${char}' == 'D'    Press Combination    Key.ShiftLeft    Key.D
	\    ...    ELSE IF    '${char}' == 'e'    Press Combination    Key.E
	\    ...    ELSE IF    '${char}' == 'E'    Press Combination    Key.ShiftLeft    Key.E
	\    ...    ELSE IF    '${char}' == 'f'    Press Combination    Key.F
	\    ...    ELSE IF    '${char}' == 'F'    Press Combination    Key.ShiftLeft    Key.F
	\    ...    ELSE IF    '${char}' == 'g'    Press Combination    Key.G
	\    ...    ELSE IF    '${char}' == 'G'    Press Combination    Key.ShiftLeft    Key.G
	\    ...    ELSE IF    '${char}' == 'h'    Press Combination    Key.H
	\    ...    ELSE IF    '${char}' == 'H'    Press Combination    Key.ShiftLeft    Key.H
	\    ...    ELSE IF    '${char}' == 'i'    Press Combination    Key.I
	\    ...    ELSE IF    '${char}' == 'I'    Press Combination    Key.ShiftLeft    Key.I
	\    ...    ELSE IF    '${char}' == 'j'    Press Combination    Key.J
	\    ...    ELSE IF    '${char}' == 'J'    Press Combination    Key.ShiftLeft    Key.J
	\    ...    ELSE IF    '${char}' == 'k'    Press Combination    Key.K
	\    ...    ELSE IF    '${char}' == 'K'    Press Combination    Key.ShiftLeft    Key.K
	\    ...    ELSE IF    '${char}' == 'l'    Press Combination    Key.L
	\    ...    ELSE IF    '${char}' == 'L'    Press Combination    Key.ShiftLeft    Key.L
	\    ...    ELSE IF    '${char}' == 'm'    Press Combination    Key.M
	\    ...    ELSE IF    '${char}' == 'M'    Press Combination    Key.ShiftLeft    Key.M
	\    ...    ELSE IF    '${char}' == 'n'    Press Combination    Key.N
	\    ...    ELSE IF    '${char}' == 'N'    Press Combination    Key.ShiftLeft    Key.N
	\    ...    ELSE IF    '${char}' == 'o'    Press Combination    Key.O
	\    ...    ELSE IF    '${char}' == 'O'    Press Combination    Key.ShiftLeft    Key.O
	\    ...    ELSE IF    '${char}' == 'p'    Press Combination    Key.P
	\    ...    ELSE IF    '${char}' == 'P'    Press Combination    Key.ShiftLeft    Key.P
	\    ...    ELSE IF    '${char}' == 'q'    Press Combination    Key.Q
	\    ...    ELSE IF    '${char}' == 'Q'    Press Combination    Key.ShiftLeft    Key.Q
	\    ...    ELSE IF    '${char}' == 'r'    Press Combination    Key.R
	\    ...    ELSE IF    '${char}' == 'R'    Press Combination    Key.ShiftLeft    Key.R
	\    ...    ELSE IF    '${char}' == 's'    Press Combination    Key.S
	\    ...    ELSE IF    '${char}' == 'S'    Press Combination    Key.ShiftLeft    Key.S
	\    ...    ELSE IF    '${char}' == 't'    Press Combination    Key.T
	\    ...    ELSE IF    '${char}' == 'T'    Press Combination    Key.ShiftLeft    Key.T
	\    ...    ELSE IF    '${char}' == 'u'    Press Combination    Key.U
	\    ...    ELSE IF    '${char}' == 'U'    Press Combination    Key.ShiftLeft    Key.U
	\    ...    ELSE IF    '${char}' == 'v'    Press Combination    Key.V
	\    ...    ELSE IF    '${char}' == 'V'    Press Combination    Key.ShiftLeft    Key.V
	\    ...    ELSE IF    '${char}' == 'w'    Press Combination    Key.W
	\    ...    ELSE IF    '${char}' == 'W'    Press Combination    Key.ShiftLeft    Key.W
	\    ...    ELSE IF    '${char}' == 'x'    Press Combination    Key.X
	\    ...    ELSE IF    '${char}' == 'X'    Press Combination    Key.ShiftLeft    Key.X
	\    ...    ELSE IF    '${char}' == 'y'    Press Combination    Key.Y
	\    ...    ELSE IF    '${char}' == 'Y'    Press Combination    Key.ShiftLeft    Key.Y
	\    ...    ELSE IF    '${char}' == 'z'    Press Combination    Key.Z
	\    ...    ELSE IF    '${char}' == 'Z'    Press Combination    Key.ShiftLeft    Key.Z
	\    ...    ELSE IF    '${char}' == '0'    Press Combination    Key.0
	\    ...    ELSE IF    '${char}' == '1'    Press Combination    Key.1
	\    ...    ELSE IF    '${char}' == '2'    Press Combination    Key.2
	\    ...    ELSE IF    '${char}' == '3'    Press Combination    Key.3
	\    ...    ELSE IF    '${char}' == '4'    Press Combination    Key.4
	\    ...    ELSE IF    '${char}' == '5'    Press Combination    Key.5
	\    ...    ELSE IF    '${char}' == '6'    Press Combination    Key.6
	\    ...    ELSE IF    '${char}' == '7'    Press Combination    Key.7
	\    ...    ELSE IF    '${char}' == '8'    Press Combination    Key.8
	\    ...    ELSE IF    '${char}' == '9'    Press Combination    Key.9
	\    ...    ELSE IF    '${Lang}' == '0407' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '040C' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0410' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0411' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0413' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0419' and '${char}' == '@'    Press Combination    Key.@
	\    ...    ELSE IF    '${Lang}' == '0C0A' and '${char}' == '@'    Press Combination    Key.@
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
	
Wait For Varied
    [Arguments]    ${reference_image}    ${timeout}
	Take A Screenshot
	${result} =    Create List    FAIL    ${EMPTY}
	${count} =    Evaluate    ${timeout} / 20
    :FOR    ${INDEX}    IN RANGE    0    ${count}
	\    Take A Screenshot	
	\    ${result} =    Does Varied Exist    ${reference_image}
	\    Run Keyword If    '@{result}[0]' == 'PASS'    Exit For Loop
	\    Sleep    20s
	Run Keyword If    '@{result}[0]' == 'FAIL'    Fail