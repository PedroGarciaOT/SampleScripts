cls 

SET PATH=%USERPROFILE%\fortify\tools\bin;%PATH%

REM # use setenv script to set environment variables
call setenv.bat

ECHO ON
ECHO " PATH=%PATH%"
ECHO " FOD_API_URL=%FOD_API_URL%"
ECHO " DEBRICKED_OSS_REPO=%DEBRICKED_OSS_REPO%"
ECHO " DEBRICKED_OSS_BRANCH=%DEBRICKED_OSS_BRANCH%"
ECHO " FOD_DEBRICKED_IMPORT_TARGET_RELEASE_ID=%FOD_DEBRICKED_IMPORT_TARGET_RELEASE_ID%"

fcli fod session login --url %FOD_API_URL% --user %FOD_USER% --password %FOD_PASSWORD% --tenant %FOD_TENANT% -k

fcli fod oss-scan import-debricked --branch %DEBRICKED_OSS_BRANCH% --repository %DEBRICKED_OSS_REPO% --release %FOD_DEBRICKED_IMPORT_TARGET_RELEASE_ID% --debricked-access-token %DEBRICKED_PAT% --file "debricked-sbom.json" --chunk-size 20000000 --connect-timeout "3m" --socket-timeout "3m" --progress "auto" -k

fcli fod session logout