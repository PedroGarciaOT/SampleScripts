#!/bin/bash
clear
echo "-========== PIPELINE SETTINGS ==========-"
# export environment variables 
# export SC_CLIENT_DIR=${HOME}/fortify/tools/sc-client/${SC_SAST_SENSOR_VERSION}/
export SC_CLIENT_DIR=$(pwd)/sc-client/${SC_SAST_SENSOR_VERSION}
export PATH=${SC_CLIENT_DIR}/bin;${HOME}/fortify/tools/bin;${PATH}

# use setenv script to export environment variables
export ENV_FILE="./setenv.sh"
if [ -f ${ENV_FILE} ]; then 
    echo "ENV_FILE=${ENV_FILE}"
    #sudo chmod +x ${ENV_FILE}
    ${ENV_FILE}    
fi

echo "======================================================================"
echo " PATH=${PATH}"
echo " SSC_URL=${SSC_URL}"
echo " SC_SAST_URL=${SC_SAST_URL}"
echo " SC_SAST_SENSOR_VERSION=${SC_SAST_SENSOR_VERSION}"
echo " SSC_USER=${SSC_USER}"
echo " SSC_APPLICATION_NAME=${SSC_APPLICATION_NAME}"
echo " SSC_VERSION_NAME=${SSC_VERSION_NAME}"
echo " SSC_VERSION_ID=${SSC_VERSION_ID}"
echo " GIT_BRANCH=${GIT_BRANCH}"
echo " GIT_REPO=${GIT_REPO}"
echo "======================================================================"
echo "-========== PRE-BUILD TASKS ==========-"


curl -s -S -o scancentral.zip -H "fortify-client: ${SC_SAST_TOKEN}" ${SC_SAST_URL}/rest/v2/update/download
mkdir -p ${SC_CLIENT_DIR}/
unzip -qq -o scancentral.zip -d ${SC_CLIENT_DIR}/

# scancentral -url ${SC_SAST_URL} update
# scancentral -sscurl ${SSC_URL} -ssctoken ${SC_SAST_CTRL_TOKEN} update

git clone -b ${GIT_BRANCH} ${GIT_REPO} ./TargetApplication
cd ./TargetApplication

# export SCANCENTRAL_BUILD_OPTS=
# # scancentral -sscurl <ssc_url> -ssctoken <token> start ‑upload -versionid <app_version_id>
# scancentral -sscurl ${SSC_URL} -ssctoken ${SSC_CI_TOKEN} start -upload -versionid ${SSC_VERSION_ID}
scancentral -sscurl ${SSC_URL} -ssctoken ${SSC_CI_TOKEN} start -upload -application ${SSC_APPLICATION_NAME} -version ${SSC_VERSION_NAME}

