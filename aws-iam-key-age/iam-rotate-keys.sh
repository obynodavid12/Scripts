#!/bin/bash

set -euo pipefail

# ------------------------------------------
# IAM Users
# ------------------------------------------

IAM_USERS=(
    "obi-devops"
    "test-user"
    "devops-cloud"
    "abc-obi-xyz-com-user"
)

# Store newly created key IDs
declare -A NEW_KEYS

echo "====================================================="
echo "Creating new access keys..."
echo "====================================================="

for IAM_USER in "${IAM_USERS[@]}"; do

    echo
    echo "Processing: $IAM_USER"

    OUTPUT_FILE="new_credentials_${IAM_USER}.csv"

    # Check existing key count
    KEY_COUNT=$(aws iam list-access-keys \
        --user-name "$IAM_USER" \
        --query 'length(AccessKeyMetadata)' \
        --output text)

    if [[ "$KEY_COUNT" -ge 2 ]]; then
        echo "Skipping $IAM_USER - already has $KEY_COUNT access keys."
        continue
    fi

    # Create new key
    if ! NEW_ACCESS_KEY=$(aws iam create-access-key \
        --user-name "$IAM_USER" \
        --query 'AccessKey' \
        --output json); then

        echo "Failed to create access key for $IAM_USER"
        continue
    fi

    ACCESS_KEY_ID=$(echo "$NEW_ACCESS_KEY" | jq -r '.AccessKeyId')
    SECRET_ACCESS_KEY=$(echo "$NEW_ACCESS_KEY" | jq -r '.SecretAccessKey')

    NEW_KEYS["$IAM_USER"]="$ACCESS_KEY_ID"

    cat > "$OUTPUT_FILE" <<EOF
IAM_USER,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY
$IAM_USER,$ACCESS_KEY_ID,$SECRET_ACCESS_KEY
EOF

    chmod 600 "$OUTPUT_FILE"

    echo "Created new key: $ACCESS_KEY_ID"
    echo "Saved credentials to: $OUTPUT_FILE"

done

echo
echo "====================================================="
echo "New access key creation complete."
echo "====================================================="

# Prompt only once
read -rp "Disable ALL old access keys now? (y/N): " DISABLE

if [[ "$DISABLE" =~ ^[Yy]$ ]]; then

    echo
    echo "Disabling old access keys..."

    for IAM_USER in "${!NEW_KEYS[@]}"; do

        NEW_KEY="${NEW_KEYS[$IAM_USER]}"

        echo
        echo "User: $IAM_USER"

        OLD_KEYS=$(aws iam list-access-keys \
            --user-name "$IAM_USER" \
            --query "AccessKeyMetadata[?AccessKeyId!='${NEW_KEY}'].AccessKeyId" \
            --output text)

        if [[ -z "$OLD_KEYS" ]]; then
            echo "No old keys found."
            continue
        fi

        for OLD_KEY in $OLD_KEYS; do
            echo "Disabling $OLD_KEY"

            aws iam update-access-key \
                --user-name "$IAM_USER" \
                --access-key-id "$OLD_KEY" \
                --status Inactive
        done

    done

    echo
    echo "Old access keys have been disabled."

else
    echo
    echo "Old access keys remain active."
fi

echo
echo "====================================================="
echo "Current access keys"
echo "====================================================="

for IAM_USER in "${IAM_USERS[@]}"; do

    echo
    echo "User: $IAM_USER"

    aws iam list-access-keys \
        --user-name "$IAM_USER" \
        --output table

done

echo
echo "Done."
