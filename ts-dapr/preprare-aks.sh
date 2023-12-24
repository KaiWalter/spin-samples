#!/bin/bash

set -e

source <(cat $(git rev-parse --show-toplevel)/.env)

if [ -z $AZURE_ENV_NAME ]; then
  terraform output -state=$TARGET_INFRA_FOLDER/terraform.tfstate -raw kube_config > ~/.kube/config
  RESOURCE_GROUP_NAME=`terraform output -state=$TARGET_INFRA_FOLDER/terraform.tfstate -json script_vars | jq -r .resource_group`
else
  RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
fi

AZURE_CONTAINER_REGISTRY_NAME=`az resource list -g $RESOURCE_GROUP_NAME --resource-type Microsoft.ContainerRegistry/registries --query '[0].name' -o tsv`
CLUSTER_NAME=`az aks list -g $RESOURCE_GROUP_NAME --query [].name -o tsv`

# az aks update -n $CLUSTER_NAME -g $RESOURCE_GROUP_NAME --attach-acr $AZURE_CONTAINER_REGISTRY_NAME

# if [[ ! -z "$(helm repo list | grep kwasm)" ]];
# then
#   helm repo add kwasm http://kwasm.sh/kwasm-operator/
# fi
#
# helm upgrade --install -n kwasm --create-namespace kwasm-operator kwasm/kwasm-operator
#
# kubectl annotate node --all kwasm.sh/kwasm-node=true

helm upgrade --install spin-containerd-shim-installer oci://ghcr.io/fermyon/charts/spin-containerd-shim-installer \
  -n kube-system \
  --version 0.10.0

kubectl apply -f https://raw.githubusercontent.com/deislabs/containerd-wasm-shims/main/deployments/workloads/runtime.yaml

dapr init -k
