ECHO OFF
cls
ECHO "-========== PIPELINE SETTINGS ==========-"
REM # Set environment variables 
set PATH=%USERPROFILE%\fortify\tools\bin;%PATH%

REM # use setenv script to set environment variables
call setenv.bat

ECHO ON
ECHO "======================================================================"
ECHO " PATH=%PATH%"
ECHO " SSC_URL=%SSC_URL%"
ECHO " SC_SAST_URL=%SC_SAST_URL%"
ECHO " SC_SAST_SENSOR_VERSION=%SC_SAST_SENSOR_VERSION%"
ECHO " SSC_USER=%SSC_USER%"
ECHO " SSC_NEW_APPLICATION_NAME=%SSC_NEW_APPLICATION_NAME%"
ECHO " SSC_NEW_VERSION_NAME=%SSC_NEW_VERSION_NAME%"
ECHO " SSC_APPLICATION_NAME=%SSC_APPLICATION_NAME%"
ECHO " SSC_VERSION_NAME=%SSC_VERSION_NAME%"
ECHO " SSC_VERSION_ID=%SSC_VERSION_ID%"
ECHO " GIT_BRANCH=%GIT_BRANCH%"
ECHO " GIT_REPO=%GIT_REPO%"
ECHO "======================================================================"
ECHO "-========== PRE-BUILD TASKS ==========-"
REM # Clone Repo
git clone -b %GIT_BRANCH% %GIT_REPO% TargetApplication

REM # Download and unpack fcli 
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-windows.zip -o fcli-windows.zip
unzip -qq -o fcli-windows.zip -d .\

REM # Install tools
fcli tool definitions update

fcli tool sc-client install --version latest

fcli tool debricked-cli install --version latest

ECHO "======================================================================"
ECHO "-========== BUILD TASKS ==========-"
cd TargetApplication

call scancentral package -o ..\package.zip

cd ..
ECHO "======================================================================"
ECHO "-========== POST-BUILD TASKS ==========-"
REM # Login into SSC
REM #fcli ssc session login --url %SSC_URL% --user %SSC_USER% --password %SSC_PASSWORD% -k
REM #fcli ssc session login --url %SSC_URL% --token %SSC_TOKEN% -k
fcli ssc session login --url %SSC_URL% --ci-token %SSC_CI_TOKEN% -k

REM # TODO Create a new application

REM # Create release
fcli ssc appversion create --copy-from %SSC_VERSION_ID% --skip-if-exists --store sscappversion %SSC_APPLICATION_NAME%:%SSC_NEW_VERSION_NAME%

REM # Print release details
fcli util variable contents sscappversion -o json

REM # Login into SC SAST
fcli sc-sast session login --client-auth-token %SC_SAST_CLIENT_TOKEN% --ssc-url %SSC_URL% --ssc-ci-token %SSC_CI_TOKEN% -k

REM # Start scan
fcli sc-sast scan start --sensor-version %SC_SAST_SENSOR_VERSION% --publish-to "::sscappversion::"  -p package.zip --store scsastscan

REM # Print scan request details
fcli util variable contents scsastscan -o json

REM # Wait for scan to finish
fcli sc-sast scan wait-for --interval "3m" "::scsastscan::"

REM # Run quality gate
fcli ssc action run check-policy --appversion "::sscappversion::"

REM # Logout from SSC
fcli ssc session logout
