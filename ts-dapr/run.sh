#!/bin/bash

set -e

source <(cat $(git rev-parse --show-toplevel)/.env)

RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
SERVICEBUS_NAMESPACE=`az resource list -g $RESOURCE_GROUP_NAME --resource-type Microsoft.ServiceBus/namespaces --query '[0].name' -o tsv`
SERVICEBUS_CONNECTION=`az servicebus namespace authorization-rule keys list -g $RESOURCE_GROUP_NAME --namespace-name $SERVICEBUS_NAMESPACE -n RootManageSharedAccessKey --query primaryConnectionString -o tsv`

JSON_STRING=$( jq -n \
                  --arg sbc "$SERVICEBUS_CONNECTION" \
                  '{SERVICEBUS_CONNECTION: $sbc}' )
echo $JSON_STRING > ./.secrets.json
APP_ID=${1,,}

case $APP_ID in
  distributor)
    APP_PORT=3001
    DAPR_HTTP_PORT=3501
    ;;
  receiver-express)
    APP_PORT=3002
    DAPR_HTTP_PORT=3502
    ;;
  receiver-standard)
    APP_PORT=3003
    DAPR_HTTP_PORT=3503
    ;;
esac

if  [ -z $APP_PORT ]; then
  echo "invalid application id" $APP_ID
else
  export SPIN_VARIABLE_DAPR_URL=http://localhost:$DAPR_HTTP_PORT

  dapr run --app-id ${APP_ID} \
      --app-port ${APP_PORT} \
      --dapr-http-port ${DAPR_HTTP_PORT} \
      --enable-app-health-check \
      --app-health-probe-interval 60 \
      --resources-path ./components-$APP_ID/ \
      --config ./components-$APP_ID/config.yaml \
      -- spin up --listen localhost:$APP_PORT
fi
