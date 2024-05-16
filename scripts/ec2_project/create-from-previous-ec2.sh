#!/bin/bash

existing_instance_name="UbuntuInstance"
ami_id="ami-09040d770ffe2224f"
region="us-east-2"

# Get information about the existing instance
existing_instance=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$existing_instance_name" --query 'Reservations[0].Instances[0]' --output json 2>/dev/null)

# Extract necessary details
EXISTING_INSTANCE_ID=$(jq -r '.InstanceId' <<< "$existing_instance")
EXISTING_INSTANCE_TAGS=$(jq -r '.Tags[] | "\(.Key)=\(.Value)"' <<< "$existing_instance")
EXISTING_INSTANCE_SUBNET_ID=$(jq -r '.SubnetId' <<< "$existing_instance")
EXISTING_SECURITY_GROUPS=$(jq -r '.SecurityGroups[].GroupId' <<< "$existing_instance")

# Launch a new EC2 instance with the same name, security group, and other properties
new_instance_id="$(aws ec2 run-instances \
    --image-id $ami_id \
    --count 1 \
    --instance-type $(jq -r '.InstanceType' <<< "$existing_instance") \
    --key-name $(jq -r '.KeyName' <<< "$existing_instance") \
    --security-group-ids $EXISTING_SECURITY_GROUPS \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$existing_instance_name}]" \
    --query "Instances[0].InstanceId" \
    --output text)" &&
aws ec2 wait instance-running --instance-ids "$new_instance_id" --region $region



# while STATE=$(aws ec2 describe-instances --instance-ids $new_instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$STATE" != "running"; do
#     sleep 1;
# done;

echo "New EC2 instance with the name $existing_instance_name has been created successfully."
