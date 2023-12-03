#!/bin/bash

set -e

source <(cat $(git rev-parse --show-toplevel)/.env)

RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
AZURE_CONTAINER_REGISTRY_NAME=`az resource list --tag azd-env-name=$AZURE_ENV_NAME --query "[?type=='Microsoft.ContainerRegistry/registries'].name" -o tsv`
AZURE_CONTAINER_REGISTRY_ENDPOINT=`az acr show -n $AZURE_CONTAINER_REGISTRY_NAME --query loginServer -o tsv`
AZURE_CONTAINER_REGISTRY_PASSWORD=`az acr credential show -n $AZURE_CONTAINER_REGISTRY_NAME --query "passwords[0].value" -o tsv
`

outfile=./.registries.yaml

echo "configs:" > $outfile
echo "  $AZURE_CONTAINER_REGISTRY_ENDPOINT:" >> $outfile
echo "    auth:" >> $outfile
echo "      username: $AZURE_CONTAINER_REGISTRY_NAME" >> $outfile
echo "      password: $AZURE_CONTAINER_REGISTRY_PASSWORD" >> $outfile

if [[ ! -z "$(k3d cluster list | grep wasm-cluster)" ]];
then
  k3d cluster delete wasm-cluster
fi

k3d cluster create wasm-cluster --image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.10.0 -p "8081:80@loadbalancer" --agents 2 --registry-config $outfile
kubectl apply -f https://github.com/deislabs/containerd-wasm-shims/raw/main/deployments/workloads/runtime.yaml
dapr init -k

rm $outfile
