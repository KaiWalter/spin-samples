# Spin WebAssembly samples

## dependencies

### Spin

```
curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
sudo mv ./spin /usr/local/bin/spin
```

### Rust WASM

```
rustup target add wasm32-wasi
```

### Dapr

```
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
dapr init
```

### yq

```
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq
```

## install Docker and make docker build wasm ready

from <https://github.com/deislabs/containerd-wasm-shims/issues/87#issuecomment-1510404441>
or <https://github.com/deislabs/containerd-wasm-shims/blob/main/deployments/k3d/DockerSetup.md>

```
curl -fsSL https://test.docker.com -o test-docker.sh
sudo sh test-docker.sh
```

```
sudo sh -c "cat >>/etc/docker/daemon.json" <<-EOF
{
    "features": {
        "containerd-snapshotter": true
    }
}
EOF
```

## install kubectl and K3D

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl

wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

## get demo WASM workload running on K3D

<https://github.com/deislabs/containerd-wasm-shims/blob/main/deployments/k3d/README.md#how-to-run-the-example>

> but currently results in `* Empty reply from server`

### my variant

```
k3d cluster create wasm-cluster --image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.10.0 -p "8081:80@loadbalancer" --agents 2 --registry-config ./.registries.yaml
kubectl apply -f https://github.com/deislabs/containerd-wasm-shims/raw/main/deployments/workloads/runtime.yaml
dapr init -k
```

```
k3d cluster delete wasm-cluster
```

## Links

<https://dev.to/thangchung/how-to-run-webassemblywasi-application-spin-with-dapr-on-kubernetes-2b8n>
<https://github.com/fermyon/spin>

## to look into

<https://github.com/engineerd/wasm-to-oci/blob/master/README.md>

## pods stuck in Terminating helpers

```
kubectl get events --sort-by=.metadata.creationTimestamp
```
