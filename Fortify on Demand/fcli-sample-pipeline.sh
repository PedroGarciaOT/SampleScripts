#!/bin/bash
clear
echo "-========== PIPELINE SETTINGS ==========-"
# export environment variables 
export PATH=${HOME}/fortify/tools/bin:${PATH}
export FOD_URL="https://api.ams.fortify.com/"
# export FOD_CLIENT_ID=
# export FOD_CLIENT_SECRET=
# export FOD_USER=
# export FOD_PASSWORD=
# export FOD_TENANT=

# Entitlement Id is available at https://ams.fortify.com/Admin/Entitlements
# export FOD_ENTITLEMENT_ID=

# export FOD_NEW_APPLICATION=
# export FOD_NEW_APPLICATION_RELEASE=

# export FOD_APPLICATION=
# export FOD_RELEASE=

# use setenv script to set environment variables
export ENV_FILE="./setenv.sh"
if [ -f ${ENV_FILE} ]; then 
    echo "ENV_FILE=${ENV_FILE}"
    #sudo chmod +x ${ENV_FILE}
    ${ENV_FILE}    
fi

echo " PATH=${PATH}"
echo " FOD_URL=${FOD_URL}"
echo " FOD_CLIENT_ID=${FOD_CLIENT_ID}"
echo " FOD_USER=${FOD_USER}"
echo " FOD_TENANT=${FOD_TENANT}"
echo " FOD_ENTITLEMENT_ID=${FOD_ENTITLEMENT_ID}"
echo " FOD_NEW_APPLICATION=${FOD_NEW_APPLICATION}"
echo " FOD_NEW_APPLICATION_RELEASE=${FOD_NEW_APPLICATION_RELEASE}"
echo " FOD_APPLICATION=${FOD_APPLICATION}"
echo " FOD_RELEASE=${FOD_RELEASE}"

echo "-========== PRE-BUILD TASKS ==========-"
# Clone Repo
git clone -b main https://github.com/fortify/IWA-Java.git ./TargetApplication

# Download and unpack fcli 
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-linux.tgz -o fcli-linux.tgz
tar -pxzf fcli-linux.tgz
source ./fcli_completion

echo "# Install tools"
./fcli tool sc-client install --version latest

./fcli tool fod-uploader install --version latest

./fcli tool debricked-cli install --version latest

echo "-========== BUILD TASKS ==========-"
cd ./TargetApplication

# Build and resolve dependencies
# mvn clean package

# TODO Add Reachability Analysis

echo "# Package application"
scancentral package -oss -o ../package.zip

cd ../

echo "-========== POST-BUILD TASKS ==========-"
echo "# Login into Fortify on Demand"
#./fcli fod session login --url ${FOD_URL} --client-id ${FOD_CLIENT_ID} --client-secret ${FOD_CLIENT_SECRET} -k
./fcli fod session login --url ${FOD_URL} --user ${FOD_USER} --password ${FOD_PASSWORD} --tenant ${FOD_TENANT} -k

# Create an application
# ./fcli fod app create ${FOD_NEW_APPLICATION} --auto-required-attrs --criticality "High" -d "FCLI created application" --delim "application:release" --owner ${FOD_USER} --release ${FOD_NEW_APPLICATION_RELEASE} --release-description "FCLI created release" --status "Production" --type "Web" --store fodapp 

# Print application details
# ./fcli util variable contents fodapp -o json

echo "# Create release"
./fcli fod release create ${FOD_APPLICATION}:${FOD_RELEASE} --status Production  --skip-if-exists --store fodrel

echo "# Print release details"
./fcli util variable contents fodrel -o json

echo "# Setup subscription"
./fcli fod sast setup --release "::fodrel::" --assessment-type "Static Assessment" --frequency "Subscription" --entitlement-id ${FOD_ENTITLEMENT_ID} --technology-stack "Auto Detect" --audit-preference "Automated" --use-aviator --oss -o json

echo "# Submit scan request"
./fcli fod sast-scan start --release "::fodrel::" -f package.zip --store fodscan

echo "# Print scan request details"
./fcli util variable contents fodscan -o json

echo "# Wait for scan to finish"
./fcli fod sast-scan wait-for "::fodscan::" --interval "3m"

echo "# Run quality/security gate"
./fcli fod action run check-policy --release "::fodrel::"

echo "# Logout from Fortify on Demand"
./fcli fod session logout