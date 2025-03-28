#!/bin/bash
clear
echo "-========== PIPELINE SETTINGS ==========-"
# export environment variables 
export PATH=${HOME}/fortify/tools/bin;${PATH}

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
echo " SSC_NEW_APPLICATION_NAME=${SSC_NEW_APPLICATION_NAME}"
echo " SSC_NEW_VERSION_NAME=${SSC_NEW_VERSION_NAME}"
echo " SSC_APPLICATION_NAME=${SSC_APPLICATION_NAME}"
echo " SSC_VERSION_NAME=${SSC_VERSION_NAME}"
echo " SSC_VERSION_ID=${SSC_VERSION_ID}"
echo " GIT_BRANCH=${GIT_BRANCH}"
echo " GIT_REPO=${GIT_REPO}"
echo "======================================================================"
echo "-========== PRE-BUILD TASKS ==========-"
## Clone Repo
git clone -b ${GIT_BRANCH} ${GIT_REPO} ./TargetApplication

# Download and unpack fcli 
#curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-mac.tgz -o fcli-mac.tgz
#tar -pxzf fcli-mac.tgz
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-linux.tgz -o fcli-linux.tgz
tar -pxzf fcli-linux.tgz

source ./fcli_completion

## Install tools
./fcli tool definitions update

./fcli tool sc-client install --version latest --client-auth-token ${SC_SAST_TOKEN} --confirm

./fcli tool debricked-cli install --version latest -y

echo "======================================================================"
echo "-========== BUILD TASKS ==========-"
cd ./TargetApplication

echo "# Package application"

scancentral package -o ..\package.zip

cd ../

echo "======================================================================"
echo "-========== POST-BUILD TASKS ==========-"
echo "# Login into SSC"
# ./fcli ssc session login --url ${SSC_URL} --user ${SSC_USER} --password ${SSC_PASSWORD} -k
# ./fcli ssc session login --url ${SSC_URL} --token ${SSC_TOKEN} -k
./fcli ssc session login --url ${SSC_URL} --token ${SSC_CI_TOKEN} --sc-sast-url ${SC_SAST_URL} --client-auth-token ${SC_SAST_TOKEN} -k

## TODO Create a new application

echo "# Create version"
./fcli ssc appversion create --copy-from ${SSC_VERSION_ID} --skip-if-exists --store sscappversion ${SSC_APPLICATION_NAME}:${SSC_NEW_VERSION_NAME}

echo "# Print release details"
./fcli util variable contents sscappversion -o json

echo "# Login into SC SAST"
./fcli sc-sast session login --client-auth-token  ${SC_SAST_TOKEN} --ssc-url ${SSC_URL} --ssc-ci-token ${SSC_CI_TOKEN} -k

echo "# Start scan"
./fcli sc-sast scan start --file package.zip --publish-to "::sscappversion::" --publish-as "fcli-sample-pipeline.fpr" --store scsastscan

echo "# Print scan request details"
./fcli util variable contents scsastscan -o json

echo "# Wait for scan to finish"
./fcli sc-sast scan wait-for --interval "3m" "::scsastscan::"

echo "# Run quality gate"
./fcli ssc action run check-policy --appversion "::sscappversion::"

echo "# Logout from SSC"
./fcli ssc session logout
