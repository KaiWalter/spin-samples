# Spin WebAssembly samples

curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
sudo mv ./spin /usr/local/bin/spin

rustup target add wasm32-wasi

wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
dapr init

## install Docker and make docker build wasm ready

from <https://github.com/deislabs/containerd-wasm-shims/issues/87#issuecomment-1510404441>

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

## Links

<https://dev.to/thangchung/how-to-run-webassemblywasi-application-spin-with-dapr-on-kubernetes-2b8n>
<https://github.com/fermyon/spin>
