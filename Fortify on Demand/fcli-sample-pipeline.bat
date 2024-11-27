ECHO OFF
cls
REM # Set environment variables 
set PATH=%USERPROFILE%\fortify\tools\bin;%PATH%
set FOD_URL="https://api.ams.fortify.com/"

REM # use setenv script to set environment variables
call setenv.bat

ECHO ON

ECHO " PATH=%PATH%"
ECHO " FOD_URL=%FOD_URL%"
ECHO " FOD_CLIENT_ID=%FOD_CLIENT_ID%"
ECHO " FOD_USER=%FOD_USER%"
ECHO " FOD_TENANT=%FOD_TENANT%"
ECHO " FOD_ENTITLEMENT_ID=%FOD_ENTITLEMENT_ID%"
ECHO " FOD_NEW_APPLICATION=%FOD_NEW_APPLICATION%"
ECHO " FOD_NEW_APPLICATION_RELEASE=%FOD_NEW_APPLICATION_RELEASE%"
ECHO " FOD_APPLICATION=%FOD_APPLICATION%"
ECHO " FOD_RELEASE=%FOD_RELEASE%"

ECHO "PRE-BUILD TASKS"
REM # Clone Repo
git clone -b main https://github.com/fortify/IWA-Java.git TargetApplication

REM # Download and unpack fcli 
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-windows.zip -o fcli-windows.zip
unzip -qq fcli-windows.zip -d .\

REM # Install tools
fcli tool sc-client install --version latest

fcli tool fod-uploader install --version latest

fcli tool debricked-cli install --version latest

ECHO "BUILD TASKS"
cd TargetApplication

REM # Build and resolve dependencies
REM call mvn clean package

REM # TODO Add Reachability Analysis

REM # Package application
call scancentral package -oss -o ..\package.zip

cd ..

ECHO "POST-BUILD TASKS"
REM # Login into FoD
REM #fcli fod session login --url %FOD_URL% --client-id %FOD_CLIENT_ID% --client-secret %FOD_CLIENT_SECRET% -k
fcli fod session login --url %FOD_URL% --user %FOD_USER% --password %FOD_PASSWORD% --tenant %FOD_TENANT% -k

REM # Create an application
REM fcli fod app create %FOD_NEW_APPLICATION% --auto-required-attrs --criticality "High" -d "FCLI created application" --delim "application:release" --owner %FOD_USER% --release %FOD_NEW_APPLICATION_RELEASE% --release-description "FCLI created release" --status "Production" --type "Web" --store fodapp 

REM # Print application details
REM fcli util variable contents fodapp -o json

REM # Create release
fcli fod release create %FOD_APPLICATION%:%FOD_RELEASE% --status Production  --skip-if-exists --store fodrel

REM # Print release details
fcli util variable contents fodrel -o json

REM # Setup subscription
fcli fod sast setup --release "::fodrel::" --assessment-type "Static Assessment" --frequency "Subscription" --entitlement-id %FOD_ENTITLEMENT_ID% --technology-stack "Auto Detect" --audit-preference "Automated" --use-aviator --oss -o json

REM # Start scan
fcli fod sast-scan start --release "::fodrel::" -f package.zip --store fodscan

REM # Print scan request details
fcli util variable contents fodscan -o json

REM # Wait for scan to finish
fcli fod sast-scan wait-for "::fodscan::" --interval "3m"

REM # Run quality gate
fcli fod action run check-policy --release "::fodrel::"

REM # Logout from FoD
fcli fod session logout
