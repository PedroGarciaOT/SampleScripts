#!/bin/bash
clear
echo "-========== INSTALL FCLI AND TOOLS SETTINGS ==========-"
# export environment variables 
export PATH=${HOME}/fortify/tools/bin:${PATH}
export SC_CLIENT_VERSION=24.4.1
export DEBRICKED_CLI_VERSION=2.6.7

echo "======================================================================"
echo " PATH=${PATH}"
echo "SC_CLIENT_VERSION=${SC_CLIENT_VERSION}"
echo "DEBRICKED_CLI_VERSION=${DEBRICKED_CLI_VERSION}"
echo "======================================================================"

# Download and unpack fcli 
#curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-mac.tgz -o fcli-mac.tgz
#tar -pxzf fcli-mac.tgz
curl -sL https://github.com/fortify/fcli/releases/latest/download/fcli-linux.tgz -o fcli-linux.tgz
tar -pxzf fcli-linux.tgz
# Add completion 
source ./fcli_completion

echo "### Install tools ###"
./fcli tool definitions update

./fcli tool fcli install --version latest -y

# ./fcli tool sc-client install --version latest -y
./fcli tool sc-client install --version ${SC_CLIENT_VERSION} -y
# ./fcli tool debricked-cli install --version latest -y
./fcli tool debricked-cli install --version ${DEBRICKED_CLI_VERSION} -y
./fcli tool fod-uploader install --version latest -y

echo "### Configure SC-Client Tool ###"

if [-z "${SC_CLIENT_VERSION}"]; then
    export SC_CLIENT_CONFIG=${HOME}/fortify/tools/sc-client/${SC_CLIENT_VERSION}/Core/config/client.properties
    echo "ScanCentral Client path=${HOME}/fortify/tools/sc-client/${SC_CLIENT_VERSION}/bin"
    if [-z "${SCANCENTRAL_AUTH_TOKEN}"]; then 
        echo client_auth_token=${SCANCENTRAL_AUTH_TOKEN}>>${SC_CLIENT_CONFIG}
    fi

    if [-z "${DEBRICKED_CLI_VERSION}"]; then
        echo "Debricked CLI path=${HOME}/fortify/tools/debricked-cli/${DEBRICKED_CLI_VERSION}/bin" 
        echo debricked_cli_dir=${HOME}/fortify/tools/debricked-cli/${DEBRICKED_CLI_VERSION}/bin>>${SC_CLIENT_CONFIG}
    fi
fi
