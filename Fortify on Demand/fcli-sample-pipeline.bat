ECHO OFF
cls
ECHO "-========== PIPELINE SETTINGS ==========-"
REM # Set environment variables 
SET PATH=%USERPROFILE%\fortify\tools\bin;%PATH%

REM # use setenv script to set environment variables
call setenv.bat

ECHO "======================================================================"
ECHO " PATH=%PATH%"
ECHO " FOD_API_URL=%FOD_API_URL%"
ECHO " FOD_CLIENT_ID=%FOD_CLIENT_ID%"
ECHO " FOD_USER=%FOD_USER%"
ECHO " FOD_TENANT=%FOD_TENANT%"
ECHO " FOD_ENTITLEMENT_ID=%FOD_ENTITLEMENT_ID%"
ECHO " FOD_NEW_APPLICATION=%FOD_NEW_APPLICATION%"
ECHO " FOD_NEW_APPLICATION_RELEASE=%FOD_NEW_APPLICATION_RELEASE%"
ECHO " FOD_APPLICATION=%FOD_APPLICATION%"
ECHO " FOD_RELEASE=%FOD_RELEASE%"
ECHO " FOD_RELEASE_ID=%FOD_RELEASE_ID%"
ECHO " GIT_BRANCH=%GIT_BRANCH%"
ECHO " GIT_REPO=%GIT_REPO%"
ECHO "======================================================================"
ECHO "-========== PRE-BUILD TASKS ==========-"
ECHO "### Clone Repo ###"
git clone -b %GIT_BRANCH% %GIT_REPO% TargetApplication

ECHO "### Download and unpack fcli ###"
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-windows.zip -o fcli-windows.zip
unzip -qq -o fcli-windows.zip -d .\

ECHO "### Install tools ###"
fcli tool definitions update

fcli tool sc-client install --version latest -y

fcli tool debricked-cli install --version latest -y

fcli tool fod-uploader install --version latest -y

ECHO "======================================================================"
ECHO "-========== BUILD TASKS ==========-"
cd TargetApplication

REM # Build and resolve dependencies
REM call mvn clean package
REM call mvn package -q -DskipTests -e

REM # Reachability Analysis
REM call debricked callgraph --no-build
REM call debricked callgraph

ECHO "### Package application ###"
call scancentral package -oss -o ..\package.zip

cd ..
ECHO "======================================================================"
ECHO "-========== POST-BUILD TASKS ==========-"
ECHO "### Login into FoD ###"
REM #fcli fod session login --url %FOD_API_URL% --client-id %FOD_CLIENT_ID% --client-secret %FOD_CLIENT_SECRET% -k
fcli fod session login --url %FOD_API_URL% --user %FOD_USER% --password %FOD_PASSWORD% --tenant %FOD_TENANT% -k

REM ECHO "### Create an application ###"
REM fcli fod app create %FOD_NEW_APPLICATION% --auto-required-attrs --criticality "High" -d "FCLI created application" --delim "application:release" --owner %FOD_USER% --release %FOD_NEW_APPLICATION_RELEASE% --release-description "FCLI created release" --status "Production" --type "Web" --store fodapp 

REM ECHO "### Print application details ###"
REM fcli util variable contents fodapp -o json

ECHO "### Create release ###"
fcli fod release create %FOD_APPLICATION%:%FOD_RELEASE% --status Production  --skip-if-exists --store fodrel

ECHO "### Print release details ###"
fcli util variable contents fodrel -o json

ECHO "### Setup subscription ###"
fcli fod sast setup --release "::fodrel::" --assessment-type "Static Assessment" --frequency "Subscription" --entitlement-id %FOD_ENTITLEMENT_ID% --technology-stack "Auto Detect" --audit-preference "Automated" --use-aviator --oss -o json

ECHO "### Start scan ###"
fcli fod sast-scan start --release "::fodrel::" -f package.zip --store fodscan

ECHO "### Print scan request details ###"
fcli util variable contents fodscan -o json

ECHO "### Wait for scan to finish ###"
fcli fod sast-scan wait-for "::fodscan::" --interval "3m"

ECHO "### Run quality gate ###"
fcli fod action run check-policy --release "::fodrel::"

ECHO "### Logout from FoD ###"
fcli fod session logout
