#!/bin/bash

ninety_days_ago=$(date --date='90 days ago')
users_list=$(aws iam list-users | jq -r --arg ninety_days_ago "$ninety_days_ago" '.Users[] | select(.CreateDate < $ninety_days_ago) | .UserName')

for user in $users_list; do
    # Filter out invalid characters from the username
    user=$(echo "$user" | sed 's/[^a-zA-Z0-9+=,.@_-]//g')

    # List access keys for the user
    access_keys=$(aws iam list-access-keys --user-name "$user" | jq -r --arg ninety_days_ago "$ninety_days_ago" '.AccessKeyMetadata[] | select(.CreateDate < $ninety_days_ago) | select(.Status == "Active") | .AccessKeyId')

    # Loop through each access key
    for access_key_id in $access_keys; do
        # Check if the access key is in use
        access_key_last_used=$(aws iam get-access-key-last-used --access-key-id "$access_key_id" | jq -r '.AccessKeyLastUsed.LastUsedDate')
        if [ -z "$access_key_last_used" ]; then
            # If the access key is not in use, deactivate it
            aws iam update-access-key --user-name "$user" --access-key-id "$access_key_id" --status Inactive
            echo "Deactivated $user"
        else
            echo "Skipping deactivation of $user access key $access_key_id as it is still in use"
        fi
    done
done
