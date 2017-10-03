*** Settings ***
Documentation     A resouce file with reusable keywords and variables.
...
...               Use ImageHorizonLibrary for image recognized automation.

*** Variables ***
${DownloadDir}    C:\\users\\ivibuild\\Downloads
${SerialUltimateRetail}    TU20R22-9GR4R5S-KKVRD2G-MC6YNDJ
${BuildsDir}      \\\\corelcorp.corel.ics\\rd\\builds
&{SerialNumbers}    ProRetail=123    UltimateRetail=456    Retail=789
${Email}          buildrelease@corel.com
${en-US}          0409
${zh-TW}          0404
${de-DE}          0407
${es-ES}          0C0A
${fr-FR}          040C
${it-IT}          0410
${ja-JP}          0411
${nl-NL}          0413
${ru-RU}          0419
${LANG}           en-US    # The language subfolder we store images for recognize
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
