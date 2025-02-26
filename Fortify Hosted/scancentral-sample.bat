scancentral -url %SC_SAST_URL% update

scancentral -sscurl %SSC_URL% -ssctoken %SC_SAST_TOKEN% update

REM SET SCANCENTRAL_BUILD_OPTS=""
REM scancentral -sscurl <ssc_url> -ssctoken <token> start ‑upload -versionid <app_version_id>
REM SSC_APPLICATION_VERSION_ID
REM scancentral -sscurl %SSC_URL% -ssctoken %SC_SAST_TOKEN% start -upload -versionid %SSC_APPLICATION_VERSION_ID%
scancentral -sscurl %SSC_URL% -ssctoken %SC_SAST_TOKEN% start -upload -application %SSC_APPLICATION% -version %SSC_APPLICATION_VERSION%