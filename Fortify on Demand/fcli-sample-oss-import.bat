cls 

SET PATH=%USERPROFILE%\fortify\tools\bin;%PATH%
SET FOD_URL="https://api.ams.fortify.com/"

ECHO ON

ECHO " DEBRICKED_OSS_REPO=%DEBRICKED_OSS_REPO%"
ECHO " DEBRICKED_OSS_BRANCH=%DEBRICKED_OSS_BRANCH%"
ECHO " FOD_DEBRICKED_IMPORT_TARGET_RELEASE_ID=%FOD_DEBRICKED_IMPORT_TARGET_RELEASE_ID%"

fcli fod session login --url %FOD_URL% --user %FOD_USER% --password %FOD_PASSWORD% --tenant %FOD_TENANT% -k

fcli fod oss-scan import-debricked --branch %DEBRICKED_OSS_BRANCH% --repository %DEBRICKED_OSS_REPO% --release %FOD_DEBRICKED_IMPORT_TARGET_RELEASE_ID% --debricked-access-token %DEBRICKED_PAT% --file "debricked-sbom.json" --chunk-size 20000000 --connect-timeout "3m" --socket-timeout "3m" --progress "auto" -k

fcli fod session logout