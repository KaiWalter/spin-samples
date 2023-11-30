#!/bin/bash
source <(cat $(git rev-parse --show-toplevel)/.env)

REVISION=`date +"%s"`

az deployment sub create -f infra/main.bicep -n main-infra-$REVISION \
  -l $AZURE_LOCATION \
  -p environmentName=$AZURE_ENV_NAME \
  location=$AZURE_LOCATION
