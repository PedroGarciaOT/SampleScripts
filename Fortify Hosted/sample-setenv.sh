#!/bin/bash

# export environment variables 
export TENANT_ID=
export SSC_URL=https://ssc.${TENANT_ID}.fortifyhosted.com
export SC_SAST_URL=https://scsastctrl.${TENANT_ID}.fortifyhosted.com/scancentral-ctrl/
export SC_SAST_SENSOR_VERSION=24.4
export SC_SAST_TOKEN=
export SCANCENTRAL_VM_OPTS=-Dclient_auth_token=${SC_SAST_TOKEN} -Drestapi_connect_timeout=10000

export SSC_USER=
export SSC_PASSWORD=

export SSC_TOKEN=
export SC_SAST_CTRL_TOKEN=
export SSC_CI_TOKEN=

export SSC_NEW_APPLICATION_NAME=
export SSC_NEW_VERSION_NAME=

export SSC_APPLICATION_NAME=
export SSC_VERSION_NAME=
export SSC_VERSION_ID=

export GIT_REPO=https://github.com/fortify/IWA-Java.git
export GIT_BRANCH=main
