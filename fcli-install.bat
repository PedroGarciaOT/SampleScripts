ECHO OFF
cls
ECHO "-========== INSTALL FCLI AND TOOLS SETTINGS ==========-"
REM # Set environment variables 
SET PATH=%USERPROFILE%\fortify\tools\bin;%PATH%
SET SC_CLIENT_VERSION=24.4.1
SET DEBRICKED_CLI_VERSION=2.6.7

ECHO "======================================================================"
ECHO " PATH=%PATH%"
ECHO "SC_CLIENT_VERSION=%SC_CLIENT_VERSION%"
ECHO "DEBRICKED_CLI_VERSION=%DEBRICKED_CLI_VERSION%"
ECHO "======================================================================"

REM # Donwload and unpack fcli
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-windows.zip -o fcli-windows.zip
unzip -qq -o fcli-windows.zip -d .\

ECHO "### Install tools ###"
fcli tool definitions update

fcli tool fcli install --version latest -y

REM # fcli tool sc-client install --version latest -y
fcli tool sc-client install --version %SC_CLIENT_VERSION% -y
REM # fcli tool debricked-cli install --version latest -y
fcli tool debricked-cli install --version %DEBRICKED_CLI_VERSION% -y
fcli tool fod-uploader install --version latest -y

IF DEFINED SC_CLIENT_VERSION (
    ECHO "### Configure SC-Client Tool ###"
    SET SC_CLIENT_CONFIG=%USERPROFILE%\fortify\tools\sc-client\%SC_CLIENT_VERSION%\Core\config\client.properties
    ECHO "ScanCentral Client path=%USERPROFILE%\fortify\tools\sc-client\%SC_CLIENT_VERSION%\bin"
    IF DEFINED SCANCENTRAL_AUTH_TOKEN (ECHO client_auth_token=%SCANCENTRAL_AUTH_TOKEN%>>%SC_CLIENT_CONFIG%)
    IF DEFINED DEBRICKED_CLI_VERSION (
        ECHO "Debricked CLI path=%USERPROFILE%\fortify\tools\debricked-cli\%DEBRICKED_CLI_VERSION%\bin"
        ECHO debricked_cli_dir=%USERPROFILE:\=/%/fortify/tools/debricked-cli/%DEBRICKED_CLI_VERSION%/bin>>%SC_CLIENT_CONFIG%
    )
    ECHO "ScanCentral Client Logs path=%LocalAppData%\Fortify\scancentral-%SC_CLIENT_VERSION%\log
)
