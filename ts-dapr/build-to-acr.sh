#!/bin/bash

set -e

source <(cat $(git rev-parse --show-toplevel)/.env)

RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
AZURE_CONTAINER_REGISTRY_NAME=`az resource list --tag azd-env-name=$AZURE_ENV_NAME --query "[?type=='Microsoft.ContainerRegistry/registries'].name" -o tsv`
AZURE_CONTAINER_REGISTRY_ENDPOINT=`az acr show -n $AZURE_CONTAINER_REGISTRY_NAME --query loginServer -o tsv`

REVISION=`date +"%s"`

az acr login -n $AZURE_CONTAINER_REGISTRY_NAME

if [[ -z $(docker buildx ls | grep wasm-builder) ]]; then
  docker buildx create --name wasm-builder --platform wasi/wasm,linux/amd64
fi

IMAGE_NAME=$AZURE_CONTAINER_REGISTRY_ENDPOINT/ts-dapr:$REVISION

docker buildx use wasm-builder
docker buildx build --platform=wasi/wasm --provenance=false --push -t $IMAGE_NAME .
docker buildx use default
