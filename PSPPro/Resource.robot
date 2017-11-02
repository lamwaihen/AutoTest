*** Settings ***
Documentation     A resouce file with reusable keywords and variables.
...
...               Use ImageHorizonLibrary for image recognized automation.

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
