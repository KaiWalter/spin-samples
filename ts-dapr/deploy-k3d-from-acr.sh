#!/bin/bash

set -e

source <(cat $(git rev-parse --show-toplevel)/.env)

APP=ts-dapr
RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
AZURE_CONTAINER_REGISTRY_NAME=`az resource list --tag azd-env-name=$AZURE_ENV_NAME --query "[?type=='Microsoft.ContainerRegistry/registries'].name" -o tsv`
AZURE_CONTAINER_REGISTRY_ENDPOINT=`az acr show -n $AZURE_CONTAINER_REGISTRY_NAME --query loginServer -o tsv`
TAG=`az acr repository show-tags -n $AZURE_CONTAINER_REGISTRY_NAME --repository $APP --top 1 --orderby time_desc -o tsv`
IMAGE_NAME=$AZURE_CONTAINER_REGISTRY_ENDPOINT/$APP:$TAG

cat workload-k3d.yml | \
yq eval ".spec|=select(.selector.matchLabels.app==\"distributor\")
    .template.spec.containers[0].image = \"$IMAGE_NAME\"" | \
yq eval ".spec|=select(.selector.matchLabels.app==\"receiver-express\") 
    .template.spec.containers[0].image = \"$IMAGE_NAME\"" | \
yq eval ".spec|=select(.selector.matchLabels.app==\"receiver-standard\")
    .template.spec.containers[0].image = \"$IMAGE_NAME\"" | \
kubectl apply -f -

kubectl describe pod -l=app=distributor
