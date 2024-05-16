#!/bin/bash

STACK_NAME="DemoParameters"
REGION="us-east-2"

echo "Deleting $STACK_NAME stack"
aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION

echo "WAITING on $STACK_NAME to be deleted..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION

echo "Stack deleted successfully."
