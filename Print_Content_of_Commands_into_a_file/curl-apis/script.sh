#!/bin/bash
API1="https://api.restful-api.dev/objects"
API2="https://api.restful-api.dev/objects/1/"
API3="https://api.restful-api.dev/objects?id=3"

curl -s $API1 | jq -r '.[] | select(.id == "2") | [.name, .data.color]'; echo '---------';sleep 1;
curl -s $API2 | jq -r '. | select(.id) | [.name, .data.color]'; echo '---------';sleep 1;
curl -s $API3 | jq 'if type == "array" then .[] | .id elif type == "object" then .id else empty end'
