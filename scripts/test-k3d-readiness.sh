#!/bin/bash
k3d cluster create wasm-cluster --image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.10.0 -p "8081:80@loadbalancer" --agents 2
echo "wait for Traefik CRDs to be installed"
kubectl wait --for=condition=complete jobs.batch/helm-install-traefik-crd -n kube-system
kubectl apply -f https://github.com/deislabs/containerd-wasm-shims/raw/main/deployments/workloads/runtime.yaml
kubectl apply -f https://github.com/deislabs/containerd-wasm-shims/raw/main/deployments/workloads/workload.yaml
echo "wait for Traefik to be ready"
kubectl wait --for=condition=complete jobs.batch/helm-install-traefik -n kube-system
kubectl wait --for=condition=Ready pod $(kubectl get pod -l=app.kubernetes.io/name=traefik -n kube-system --output=jsonpath={.items..metadata.name}) -n kube-system
echo "wait 30 seconds"
sleep 30
curl -v http://127.0.0.1:8081/spin/hello
