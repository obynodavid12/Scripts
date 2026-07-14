# #!/bin/bash

# # IAM username for which to create the access key
# IAM_USER="test-user"

# # File to securely store the new credentials
# OUTPUT_FILE="new_credentials_$IAM_USER.txt"

# # Create a new access key
# echo "Creating a new access key for user: $IAM_USER..."
# NEW_ACCESS_KEY=$(aws iam create-access-key --user-name "$IAM_USER" --query 'AccessKey' --output json)

# if [ $? -ne 0 ]; then
#     echo "Error: Failed to create a new access key for $IAM_USER."
#     exit 1
# fi

# # Extract Access Key ID and Secret Access Key
# ACCESS_KEY_ID=$(echo "$NEW_ACCESS_KEY" | jq -r '.AccessKeyId')
# SECRET_ACCESS_KEY=$(echo "$NEW_ACCESS_KEY" | jq -r '.SecretAccessKey')

# echo "New Access Key ID: $ACCESS_KEY_ID"

# # Save the credentials to a file
# echo "Saving new credentials to $OUTPUT_FILE..."
# cat <<EOF > "$OUTPUT_FILE"
# AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
# EOF

# # Secure the file (optional but recommended)
# chmod 600 "$OUTPUT_FILE"

# echo "New credentials have been saved to $OUTPUT_FILE."

# # List all access keys for the user
# echo "Listing all access keys for $IAM_USER..."
# aws iam list-access-keys --user-name "$IAM_USER"

# # Optional: Disable old access keys
# echo "Do you want to disable old access keys for $IAM_USER? (y/n)"
# read -r DISABLE_OLD_KEYS

# if [ "$DISABLE_OLD_KEYS" == "y" ]; then
#     for OLD_KEY in $(aws iam list-access-keys --user-name "$IAM_USER" --query 'AccessKeyMetadata[*].AccessKeyId' --output text); do
#         if [ "$OLD_KEY" != "$ACCESS_KEY_ID" ]; then
#             echo "Deactivating old access key: $OLD_KEY..."
#             aws iam update-access-key --user-name "$IAM_USER" --access-key-id "$OLD_KEY" --status Inactive
#         fi
#     done
#     echo "Old keys have been deactivated. Review them before deletion."
# fi

# echo "Script execution completed."

# can modify the script to store them in another secure location, like AWS Secrets Manager or HashiCorp Vault.




# #!/bin/bash
# # Author Vinayak Gadad
# # Script displays users Active access keys with created date and the age of the keys.\n Only the keys that are 90 days olders


# if [[ -z "$1" ]]; then
#    echo "Profile not mentioned, Please run as ./iam_access_keyage profile"
#    exit 1
# fi

# profile=$1

# Today=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# printf "The list of all the users Active access keys with created date and the age of the keys.\n Only the keys that are 90 days olders are printed here.\n"
# function calcage(){
#         CURRENT_KEY_ID=$(aws iam list-access-keys --user-name "$user" --profile "$profile" --output json |jq '.AccessKeyMetadata[] | select(.Status == "Active")| .CreateDate' | tr -d '"')
#         ACCESS_KEY=$(aws iam list-access-keys --user-name "$user"  --profile "$profile"  --output json |jq '.AccessKeyMetadata[] | select(.Status == "Active")| .AccessKeyId' | tr -d '"')
#         CREATED_ON=$(aws iam list-access-keys --user-name "$user"  --profile "$profile" --output json |jq '.AccessKeyMetadata[] | select(.Status == "Active")| .CreateDate' | tr -d '"')
#         for dates in $CURRENT_KEY_ID;
#         do
#             d1=$(date -jf %Y-%m-%d "$Today" +%s 2> /dev/null)
#             d2=$(date -jf %Y-%m-%d "$dates" +%s 2> /dev/null)
#             keyageinsec=`expr $d1 - $d2`
#             age=`expr $keyageinsec / 86400`

#             return $age
#         done
# }

# for user in $(aws iam list-users  --profile "$profile" --output json|jq -r ".Users[].UserName");
# do
#     calcage "$user"
#     # This prints list of all the users whose keys are Active and the Access keys are 90 Days older
#     if [[ -n "$ACCESS_KEY" && $age -ge 90 ]]; then
#          printf "\nUser: $user \t Key age :$age \n"
#          printf "Keys: $ACCESS_KEY \t Created on: $CREATED_ON\n"
#     fi
# done

#!/bin/bash

# Define the threshold date (one year ago)
one_year_ago=$(date +%Y-%m-%d --date='1 year ago')

echo "Checking IAM users for access keys older than $one_year_ago..."

# Iterate through each IAM user
for user in $(aws iam list-users --query 'Users[*].UserName' --output text); do
    echo "Checking user: $user"
    
    # Get the list of access keys and their creation dates
    access_keys=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[*].[AccessKeyId,CreateDate]' --output text)
    
    # If the user has no access keys, skip to the next user
    if [ -z "$access_keys" ]; then
        echo "No access keys found for user: $user."
        continue
    fi
    
    # Iterate through each access key for the user
    while IFS=$'\t' read -r key_id create_date; do
        # Convert the creation date to YYYY-MM-DD for comparison
        key_date=$(date -d "$create_date" +%Y-%m-%d 2>/dev/null)
        
        if [[ "$key_date" < "$one_year_ago" ]]; then
            echo "User: $user, Access Key ID: $key_id, Creation Date: $key_date (OLDER than 1 year)"
        else
            echo "User: $user, Access Key ID: $key_id, Creation Date: $key_date (within acceptable range)"
        fi
    done <<< "$access_keys"
done

echo "Done checking all users."
