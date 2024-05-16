#!/usr/bin/env bash

# export AWS_DEFAULT_OUTPUT=json

# echo "output will be formatted in to columns at end" >&2
# echo "getting user list" >&2
# for username in $(aws iam list-users | jq -r '.Users[].UserName'); do
# echo "querying user $username" >&2
# aws iam list-access-keys --user-name "$username" | jq -r '.AccessKeyMetadata[] | [.UserName, .Status, .CreateDate, .AccessKeyId] | @csv'

#  done |
# column -t

# for user in $(aws iam list-users --output text --no-cli-pager | awk '{print $NF}'); do
#     aws iam list-access-keys --user $user --output text --no-cli-pager
#     test $? -gt 128 && exit
# done

# Oneliner(https://gist.github.com/mafonso/7ee51981581f544ed52c)-
#for user in $(aws iam list-users --output text --no-cli-pager| awk '{print $NF}'); do aws iam list-access-keys --user $user --output json --no-cli-pager; done | jq


# for user in $(aws iam list-users --output text | awk '{print $NF}'); do
#     aws iam list-access-keys --user $user --output text
# done

#this only prints the AccessKey value
# for user in $(aws iam list-users --query 'Users[*].UserName' --output text); do
#   aws iam list-access-keys --user $user --query "AccessKeyMetadata[].AccessKeyId" --output text
# done


users_list=$(aws iam list-users --query 'Users[*].UserName' --output text)
for user in $users_list; do
    # Filter out invalid characters from the username
    user=$(echo "$user" | sed 's/[^a-zA-Z0-9+=,.@_-]//g')
    response=$(aws iam list-access-keys --user-name "$user" --output text --query 'AccessKeyMetadata[*].[AccessKeyId,CreateDate]')
    while IFS= read -r line ; do
        user=$(echo "$user" | awk '{print $NF}'); key=$(echo "$line" | awk '{print $1}'); date=$(echo "$line" | awk '{print $2}');
        echo "$user - $key - $date"
    done <<< "$response"
done

   
# users_list=$(aws iam list-users --query 'Users[*].UserName' --output text)
# for user in $users_list; do
#     # Filter out invalid characters from the username
#     user=$(echo "$user" | sed 's/[^a-zA-Z0-9+=,.@_-]//g')  # removes any characters from the username that are not alphanumeric, plus signs, equals signs, periods, commas, underscores, or hyphens. This ensures cleaner handling of usernames during processing.
#     aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[*].[AccessKeyId, CreateDate]' --output text
# done
