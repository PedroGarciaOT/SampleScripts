ECHO OFF
cls
ECHO "-========== PIPELINE SETTINGS ==========-"
REM # Set environment variables 
REM SET SC_CLIENT_DIR=%USERPROFILE%\fortify\tools\sc-client\%SC_SAST_SENSOR_VERSION%\
SET SC_CLIENT_DIR=%cd%\sc-client\%SC_SAST_SENSOR_VERSION%\
SET PATH=%SC_CLIENT_DIR%\bin;%USERPROFILE%\fortify\tools\bin;%PATH%

REM # use setenv script to set environment variables
call setenv.bat

ECHO ON
ECHO "======================================================================"
ECHO " PATH=%PATH%"
ECHO " SSC_URL=%SSC_URL%"
ECHO " SC_SAST_URL=%SC_SAST_URL%"
ECHO " SC_SAST_SENSOR_VERSION=%SC_SAST_SENSOR_VERSION%"
ECHO " SSC_USER=%SSC_USER%"
ECHO " SSC_APPLICATION_NAME=%SSC_APPLICATION_NAME%"
ECHO " SSC_VERSION_NAME=%SSC_VERSION_NAME%"
ECHO " SSC_VERSION_ID=%SSC_VERSION_ID%"
ECHO " GIT_BRANCH=%GIT_BRANCH%"
ECHO " GIT_REPO=%GIT_REPO%"
ECHO "======================================================================"

curl -s -S -o scancentral.zip -H "fortify-client: %SC_SAST_TOKEN%" %SC_SAST_URL%/rest/v2/update/download
mkdir %SC_CLIENT_DIR%
unzip -qq -o scancentral.zip -d %SC_CLIENT_DIR%

REM scancentral -url %SC_SAST_URL% update
REM scancentral -sscurl %SSC_URL% -ssctoken %SC_SAST_CTRL_TOKEN% update

git clone -b %GIT_BRANCH% %GIT_REPO% TargetApplication
cd TargetApplication

REM SET SCANCENTRAL_BUILD_OPTS=""
REM # scancentral -sscurl <ssc_url> -ssctoken <token> start ‑upload -versionid <app_version_id>
REM scancentral -sscurl %SSC_URL% -ssctoken %SSC_CI_TOKEN% start -upload -versionid %SSC_VERSION_ID%
scancentral -sscurl %SSC_URL% -ssctoken %SSC_CI_TOKEN% start -upload -application %SSC_APPLICATION_NAME% -version %SSC_VERSION_NAME%
