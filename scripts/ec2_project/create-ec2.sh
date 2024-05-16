#!/bin/bash

# Load environment variables
source .env

# Get subnet id using AWS CLI
subnet_id=$(aws ec2 describe-subnets --region "$REGION" --query 'Subnets[].SubnetId' --output text | cut -f1)

# Create a JSON file for device mapping
cat << EOF > device.json
[
    {
        "DeviceName": "/dev/sda1",
        "Ebs": {
            "VolumeSize": 50,
            "VolumeType": "gp2",
            "DeleteOnTermination": true
        }
    }
]
EOF

# Launch Ubuntu EC2 instance with the specified configurations
instance_id=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEYNAME" \
    --subnet-id "$subnet_id" \
    --block-device-mappings file://device.json \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=UbuntuInstance}]" \
    --user-data "file://configure_coturn.txt" \
    --query 'Instances[0].InstanceId' \
    --output text)

if [ $? -eq 0 ]; then
    echo "Ubuntu EC2 instance with Coturn configured is launching....."
else
    echo "Error creating EC2 instance. Please check the logs for more information."
    exit 1
fi

# Wait for the instance to be in running state
aws ec2 wait instance-running --instance-ids "$instance_id" --region "$REGION"






