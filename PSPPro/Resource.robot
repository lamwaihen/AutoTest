*** Settings ***
Documentation     A resouce file with reusable keywords and variables.
...
...               Use ImageHorizonLibrary for image recognized automation.
Library           OperatingSystem
Library           ImageHorizonLibrary    screenshot_folder=output

*** Variables ***
${DownloadDir}    C:\\users\\ivibuild\\Downloads
${SerialUltimateRetail}    TU20R22-9GR4R5S-KKVRD2G-MC6YNDJ
${BuildsDir}      H:
&{SerialNumbers}    ProRetail=123    UltimateRetail=456    Retail=789
${CurrentLang}    en-US    # The language subfolder we store images for recognize
${ProductName}    PSPX10_BUILDS
${ProductSKU}     Ultimate
${BuildName}      \    # Build package name like "Main-Branch_20.0.0.135_PHOTOULT(QA)-RETAIL(RELEASE)_LOGID563649"
${SetupDir}       ${EMPTY}

*** Keywords ***
