#!/bin/bash

API1="https://api.restful-api.dev/objects"
echo "$API1"

curl -Ss "$API1" | jq 'if type == "array" then .[] | .id elif type == "object" then .id else empty end'
