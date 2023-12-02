#!/bin/bash
#
curl -X POST http://localhost:3501/v1.0/bindings/q-order-ingress \
  -H "Content-Type: application/json" \
  -d '{
        "data": {
          "name": "Hi"
        },
        "metadata": {
          "ttlInSeconds": "60"
        },
        "operation": "create"
      }'
