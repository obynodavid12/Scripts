#!/bin/bash
API1="https://api.restful-api.dev/objects"
API2="https://api.restful-api.dev/objects/1/"
API3="https://api.restful-api.dev/objects?id=3"
API4="http://dummy.restapiexample.com/api/v1/employees"

curl -s $API1 | jq -r '.[] | select(.id == "2") | [.name, .data.color]'; echo '---------';sleep 1;
curl -s $API1 | jq -r '.[] | select(.id == "1") | [.name, .data.color] | @tsv'
curl -s $API1 | jq 'if type == "array" then .[] | .name elif type == "object" then .id else empty end'
curl -s $API1 | jq 'if type == "array" then .[] | .id elif type == "object" then .id else empty end'
curl -s $API1 | jq '.[] | select(.name == "Apple iPhone 12 Pro Max") | .id'
curl -s $API1 | jq -r '.[] | select(.id) | [.name, .data.color] | @tsv' 
curl -s $API1 | jq '.[] | select(.name == "Google Pixel 6 Pro") | .id'
curl -s $API1 | jq -r '.[] | select(.id != "1") | [.name, .data.color] | @tsv'
curl -s $API2 | jq -r '. | select(.id) | [.name, .data.color]'; echo '---------';sleep 1;
curl -s "$API3" | jq 'if type == "array" then .[] | .id elif type == "object" then .id else empty end'
curl -s "$API3" | jq '.[] | if .id == "3" then .name else empty end'
curl -s "${API3}" | jq '.[] | select(has("id"))'  #you can use id, name or data
curl -s $API4 | jq '.data[].id'
curl -s "${API4}" | jq '.data[0].employee_name'
curl -s "${API4}" | jq -r '.data[] | select(.id) | [.employee_name, .employee_salary] | @tsv'





