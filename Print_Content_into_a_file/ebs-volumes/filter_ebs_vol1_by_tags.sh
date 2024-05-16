#!/bin/bash

# Set the AWS region from an environment variable
export AWS_REGION="${AWS_REGION:-us-east-2}"

# Define your tag key and value
tag_key="Name"
tag_value="devops_cloud"

# Filter EBS volumes by tag and status
volume_ids=$(aws ec2 describe-volumes --filters "Name=tag:${tag_key},Values=${tag_value}" "Name=status,Values=available" --query "Volumes[*].VolumeId" --output text)

# Check if there are any available volumes
if [ -z "$volume_ids" ]; then
    echo "No EBS volumes with tag ${tag_key}:${tag_value} in available state."
    exit 0
fi

# Print the volume IDs and ask for confirmation
echo "EBS volumes with tag ${tag_key}:${tag_value} in available state:"
echo "$volume_ids"

read -p "Do you want to delete these volumes? (y/n) " confirm
if [ "$confirm" = "y" ]; then
    for volume_id in $volume_ids; do
        echo "Deleting volume $volume_id"
        aws ec2 delete-volume --volume-id "$volume_id"
    done
else
    echo "Deletion cancelled."
fi