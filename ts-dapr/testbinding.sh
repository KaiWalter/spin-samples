#!/bin/bash
#
curl -X POST http://localhost:3501/v1.0/bindings/q-order-ingress \
  -H "Content-Type: application/json" \
  -d '{
        "data": {
          "Delivery": "standard"
        },
        "metadata": {
          "ttlInSeconds": "60"
        },
        "operation": "create"
      }'

curl -X POST http://localhost:3501/v1.0/bindings/q-order-ingress \
  -H "Content-Type: application/json" \
  -d '{
        "data": {
          "Delivery": "express"
        },
        "metadata": {
          "ttlInSeconds": "60"
        },
        "operation": "create"
      }'
