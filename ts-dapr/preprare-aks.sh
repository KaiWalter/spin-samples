#!/bin/bash

set -e

source <(cat $(git rev-parse --show-toplevel)/.env)

if [ ! -z "$TARGET_INFRA_FOLDER" ]; then
  pushd $TARGET_INFRA_FOLDER
  terraform apply --auto-approve \
    -var "location=$AZURE_LOCATION" \
    -var "prefix=$AZURE_ENV_NAME"
  popd
  terraform output -state=$TARGET_INFRA_FOLDER/terraform.tfstate -raw kube_config > ~/.kube/config
  RESOURCE_GROUP_NAME=`terraform output -state=$TARGET_INFRA_FOLDER/terraform.tfstate -json script_vars | jq -r .resource_group`
else
  RESOURCE_GROUP_NAME=`az group list  --query "[?starts_with(name,'$AZURE_ENV_NAME')].name" -o tsv`
fi

AZURE_CONTAINER_REGISTRY_NAME=`az resource list -g $RESOURCE_GROUP_NAME --resource-type Microsoft.ContainerRegistry/registries --query '[0].name' -o tsv`
AZURE_CONTAINER_REGISTRY_ENDPOINT=`az acr show -n $AZURE_CONTAINER_REGISTRY_NAME --query loginServer -o tsv`

#-- this does not get spin-v2 installed ...
# helm upgrade --install spin-containerd-shim-installer oci://ghcr.io/fermyon/charts/spin-containerd-shim-installer \
#   -n kube-system \
#   --version 0.10.0 \
#   --values ../../spin-k8s-bench/manifests/spin-values.yaml

#-- ... hence install from repo
az acr build --registry $AZURE_CONTAINER_REGISTRY_NAME \
  --image shim-install:latest \
  ../../spin-containerd-shim-installer/image/

az acr build --registry $AZURE_CONTAINER_REGISTRY_NAME \
  --image dapr-ambient:latest \
  ../../dapr-ambient/

helm upgrade --install spin-containerd-shim-installer ../../spin-containerd-shim-installer/chart \
  -n kube-system \
  --set image.registry=$AZURE_CONTAINER_REGISTRY_ENDPOINT \
  --set image.repository=shim-install \
  --set image.tag=latest 
  # --set nodeSelector.func-runtime=spin

if [[ -z "$(helm repo list | grep dapr)" ]];
then
  helm repo add dapr https://dapr.github.io/helm-charts/
fi

helm upgrade --install dapr dapr/dapr \
  --version=1.11 \
  --namespace dapr-system \
  --create-namespace
