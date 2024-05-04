#!/bin/bash

# Set the parameters
STACK_NAME="DemoParameters"
TEMPLATE_FILE="ssm-parameter.json"
PARAMETER_FILE="parameter-ssm.json"
TAG_FILE="tag-ssm.json"
REGION="us-east-2"

# Create the stack
echo "Creating stack..."
aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --region $REGION --capabilities CAPABILITY_IAM --parameters file://$PARAMETER_FILE --tags file://$TAG_FILE | jq -r .StackId

# Wait for the stack to be created
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION

# Describe the stack and output the result to a JSON file
aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION | jq '.' > stack-description.json

echo "Stack created successfully."
