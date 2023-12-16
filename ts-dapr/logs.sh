#!/bin/bash
case "$1" in
  re)
    service=receiver-express
    container=$service
    ;;
  red)
    service=receiver-express
    container=daprd
    ;;
  rs)
    service=receiver-standard
    container=$service
    ;;
  rsd)
    service=receiver-standard
    container=daprd
    ;;
  dd)
    service=distributor
    container=daprd
    ;;
  *)
    service=distributor
    ;;
esac


podname=`kubectl get pod -l=app=$service --output=jsonpath={.items..metadata.name}` 
kubectl logs $podname $container
