#!/bin/bash

set -e

k3d image load -c wasm-cluster ./target/ts-dapr.tar

yq eval ".spec|=select(.selector.matchLabels.app==\"distributor\")
                 .template.spec.containers[0].image =
                    \"ts-dapr\"" workload.yml | kubectl apply -f -
