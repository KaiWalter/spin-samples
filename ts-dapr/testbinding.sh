#!/bin/bash
#
curl -X POST http://localhost:3501/v1.0/bindings/q-order-ingress \
  -H "Content-Type: application/json" \
  -d '{
        "data": {
          "OrderId": 1,
          "Delivery": "Standard"
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
          "OrderId": 2,
          "Delivery": "Express"
        },
        "metadata": {
          "ttlInSeconds": "60"
        },
        "operation": "create"
      }'
