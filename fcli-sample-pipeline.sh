#!/bin/bash
clear
# export environment variables 
# setenv.sh
export PATH=/home/fortify/tools/bin;${PATH}
export FOD_URL="https://api.ams.fortify.com/"
# export FOD_CLIENT_ID=
# export FOD_CLIENT_SECRET=
export FOD_USER=
export FOD_PASSWORD=
export FOD_TENANT=

# Entitlement Id is available at https://ams.fortify.com/Admin/Entitlements
export FOD_ENTITLEMENT_ID=

export FOD_APPLICATION=
export FOD_RELEASE=
export FOD_NEW_RELEASE=

echo "PRE-BUILD TASKS"
# Clone Repo
git clone -b main https://github.com/fortify/IWA-Java.git ./TargetApplication

# Download and unpack fcli 
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-windows.zip -o fcli-windows.zip
unzip -qq fcli-windows.zip -d ./

# Install tools
fcli tool sc-client install --version latest

fcli tool fod-uploader install --version latest

echo "BUILD TASKS"
cd ./TargetApplication

# Build and resolve dependencies
# call mvn clean package

# Package application
call scancentral package -o ../package.zip

cd ../

echo "POST-BUILD TASKS"
# Login into FoD
#fcli fod session login --url ${FOD_URL} --client-id ${FOD_CLIENT_ID} --client-secret ${FOD_CLIENT_SECRET} -k
fcli fod session login --url ${FOD_URL} --user ${FOD_USER} --password ${FOD_PASSWORD} --tenant ${FOD_TENANT} -k

# Create an application
# fcli fod app create ${FOD_APPLICATION} --auto-required-attrs --criticality "High" -d "FCLI created application" --delim "application:release" --owner ${FOD_USER} --release ${FOD_RELEASE} --release-description "FCLI created release" --status "Production" --type "Web" --store fodapp 

# Print application details
# fcli util variable contents fodapp -o json

# Create release
fcli fod release create ${FOD_APPLICATION%:%FOD_NEW_RELEASE} --status Production  --skip-if-exists --store fodrel

# Print release details
fcli util variable contents fodrel -o json

# Setup subscription
fcli fod sast setup --release "::fodrel::" --assessment-type "Static Assessment" --frequency "Subscription" --entitlement-id ${FOD_ENTITLEMENT_ID} --technology-stack "Auto Detect" --audit-preference "Automated" --use-aviator -o json

# Start scan
fcli fod sast-scan start --release "::fodrel::" -f package.zip --store fodscan

# Wait for scan to finish
fcli fod sast-scan wait-for "::fodscan::scanId"

# Run quality gate
fcli fod action run check-policy --release "::fodrel::"

# Logout from FoD
fcli fod session logout
