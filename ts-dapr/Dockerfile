FROM scratch
COPY ./target/ts-dapr.wasm ./target/ts-dapr.wasm
COPY ./spin.toml /spin.toml
ENTRYPOINT ["/spin.toml"]
