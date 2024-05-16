#!/bin/bash
# Get the current instance ID FROM THE EC2 Terminals and not from local
get_instance_id() {
    if instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id); then
        echo "$instance_id"
    else
        echo "Error retrieving instance ID"
        exit 1
    fi
}

# Call the function to get the instance ID
instance_id=$(get_instance_id)
echo "The current instance ID is: $instance_id"


# get_instance_region() {
#     if [ -z "$AWS_REGION" ]; then
#         AWS_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document \
#             | grep -i region \
#             | awk -F\" '{print $4}')
#     fi

#     echo $AWS_REGION
# }

# # Call the function to get the region
# region=$(get_instance_region)
# echo "The current instance is running in the $region region."
