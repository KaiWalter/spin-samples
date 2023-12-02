#!/bin/bash

set -e

spin build

source <(cat $(git rev-parse --show-toplevel)/.env)

RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
SERVICEBUS_NAMESPACE=`az resource list -g $RESOURCE_GROUP_NAME --resource-type Microsoft.ServiceBus/namespaces --query '[0].name' -o tsv`
SERVICEBUS_CONNECTION=`az servicebus namespace authorization-rule keys list -g $RESOURCE_GROUP_NAME --namespace-name $SERVICEBUS_NAMESPACE -n RootManageSharedAccessKey --query primaryConnectionString -o tsv`

APP_ID=distributor
APP_PORT=3000
DAPR_HTTP_PORT=3501
export SPIN_VARIABLE_DAPR_URL=http://localhost:$DAPR_HTTP_PORT

JSON_STRING=$( jq -n \
                  --arg sbc "$SERVICEBUS_CONNECTION" \
                  '{SERVICEBUS_CONNECTION: $sbc}' )
echo $JSON_STRING > ./.secrets.json

dapr run --app-id ${APP_ID} \
    --app-port ${APP_PORT} \
    --dapr-http-port ${DAPR_HTTP_PORT} \
    --log-level debug \
    --enable-app-health-check \
    --app-health-probe-interval 60 \
    --resources-path ./components/ \
    --config ./components/config.yaml \
    -- spin up
