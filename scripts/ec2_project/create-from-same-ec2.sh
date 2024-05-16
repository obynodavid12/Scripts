#!/bin/bash

existing_instance_name="UbuntuInstance"
ami_id="ami-09040d770ffe2224f"

# Get information about the existing instance
existing_instance=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$existing_instance_name" --query 'Reservations[0].Instances[0]' --output json 2>/dev/null)

if [[ -z "$existing_instance" ]]; then
    echo "Error: Existing instance $existing_instance_name not found."
    exit 1
fi

# Extract necessary details
existing_instance_id=$(jq -r '.InstanceId' <<< "$existing_instance")
existing_instance_tags=$(jq -r '.Tags[] | "\(.Key)=\(.Value)"' <<< "$existing_instance")
existing_instance_subnet_id=$(jq -r '.SubnetId' <<< "$existing_instance")
existing_security_groups=$(jq -r '.SecurityGroups[].GroupId' <<< "$existing_instance")

# Launch a new EC2 instance with the same name, security group, and other properties
new_instance_id=$(aws ec2 run-instances \
    --image-id "$ami_id" \
    --count 1 \
    --instance-type "$(jq -r '.InstanceType' <<< "$existing_instance")" \
    --key-name "$(jq -r '.KeyName' <<< "$existing_instance")" \
    --security-group-ids "$existing_security_groups" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$existing_instance_name}]" \
    --query "Instances[0].InstanceId" \
    --output text)

if [[ -z "$new_instance_id" ]]; then
    echo "Error: Failed to create new instance."
    exit 1
fi

# Wait until the new instance is in the running state
while state=$(aws ec2 describe-instances --instance-ids "$new_instance_id" --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" != "running"; do
    sleep 1
done

echo "New EC2 instance with the name $existing_instance_name has been created successfully."
