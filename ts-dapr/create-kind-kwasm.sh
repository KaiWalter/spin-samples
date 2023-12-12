#!/bin/bash

set -e

source <(cat $(git rev-parse --show-toplevel)/.env)

RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
AZURE_CONTAINER_REGISTRY_NAME=`az resource list --tag azd-env-name=$AZURE_ENV_NAME --query "[?type=='Microsoft.ContainerRegistry/registries'].name" -o tsv`
AZURE_CONTAINER_REGISTRY_ENDPOINT=`az acr show -n $AZURE_CONTAINER_REGISTRY_NAME --query loginServer -o tsv`
AZURE_CONTAINER_REGISTRY_PASSWORD=`az acr credential show -n $AZURE_CONTAINER_REGISTRY_NAME --query "passwords[0].value" -o tsv
`

if [[ ! -z "$(kind get clusters | grep wasm-cluster)" ]];
then
  kind delete cluster -n wasm-cluster
fi

kind create cluster -n wasm-cluster --config ./kind-config.yaml

kubectl create secret docker-registry pull-secret \
  --docker-server=$AZURE_CONTAINER_REGISTRY_ENDPOINT \
  --docker-username=$AZURE_CONTAINER_REGISTRY_NAME \
  --docker-password=$AZURE_CONTAINER_REGISTRY_PASSWORD

kubectl apply -f https://raw.githubusercontent.com/KWasm/kwasm-node-installer/main/example/daemonset.yaml
kubectl apply -f https://raw.githubusercontent.com/deislabs/containerd-wasm-shims/main/deployments/workloads/runtime.yaml

dapr init -k

