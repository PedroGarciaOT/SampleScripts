#!/bin/bash

scancentral -url $SC_SAST_URL update

scancentral -sscurl $SSC_URL -ssctoken $SC_SAST_TOKEN update

# SET SCANCENTRAL_BUILD_OPTS=""
# scancentral -sscurl <ssc_url> -ssctoken <token> start ‑upload -versionid <app_version_id>
# SSC_APPLICATION_VERSION_ID
# scancentral -sscurl %SSC_URL% -ssctoken %SC_SAST_TOKEN% start -upload -versionid %SSC_APPLICATION_VERSION_ID%
scancentral -sscurl $SSC_URL -ssctoken $SC_SAST_TOKEN start -upload -application $SSC_APPLICATION -version $SSC_APPLICATION_VERSION
