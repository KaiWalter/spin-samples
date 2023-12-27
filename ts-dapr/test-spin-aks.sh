#!/bin/bash

set -e

LOCAL_PORT=8080
POD_PORT=80

case "$1" in
  e)
    SERVICE=receiver-express-svc
    ;;
  s)
    SERVICE=receiver-standard-svc
    ;;
  *)
    SERVICE=distributor-svc
    ;;
esac

# clean up the background port forward process on exit
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

echo "starting port forward to $SERVICE"
kubectl port-forward "svc/$SERVICE" $LOCAL_PORT:$POD_PORT > /dev/null 2>&1 &

echo "waiting for port forward to be ready"
timeout 5 sh -c 'until nc -z $0 $1; do sleep 1; done' '127.0.0.1' $LOCAL_PORT

curl -v http://127.0.0.1:$LOCAL_PORT/.well-known/spin/health
echo -e "\r"
curl -v http://127.0.0.1:$LOCAL_PORT/dapr-metadata
echo -e "\r"
