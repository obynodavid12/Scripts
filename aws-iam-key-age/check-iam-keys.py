#!/usr/bin/env python3
"""
IAM Access Key Age Reporter

Usage: python iam_key_age.py [filter_pattern]

filter_pattern (optional) - regex pattern to filter usernames.
    Example: ".*-.*" to show only hyphenated names.

Output: Tabular list of all access keys (Active and Inactive) with
        age in days and last used date.
"""

import sys
import re
from datetime import datetime, timezone
import boto3
from tabulate import tabulate   # <-- added import

# ----------------------
# AWS Setup (default credentials)
# ----------------------
iam = boto3.client('iam')


def get_age_days(create_date_str):
    """Return age in days from CreateDate (ISO 8601) to now."""
    create_dt = datetime.fromisoformat(create_date_str.replace('Z', '+00:00'))
    now = datetime.now(timezone.utc)
    delta = now - create_dt
    return delta.days


def list_all_users():
    """Paginate through all IAM users and return list of user names."""
    users = []
    paginator = iam.get_paginator('list_users')
    for page in paginator.paginate():
        for user in page['Users']:
            users.append(user['UserName'])
    return users


def get_access_keys(username):
    """
    Return list of access key metadata for a given user (both Active/Inactive).
    Also fetches the last used date for each key.
    """
    keys = []
    try:
        paginator = iam.get_paginator('list_access_keys')
        for page in paginator.paginate(UserName=username):
            for key in page['AccessKeyMetadata']:
                # Add last used info
                try:
                    last_used_resp = iam.get_access_key_last_used(
                        AccessKeyId=key['AccessKeyId']
                    )
                    last_used = last_used_resp.get('AccessKeyLastUsed', {}).get('LastUsedDate')
                    key['LastUsedDate'] = last_used.strftime('%Y-%m-%d') if last_used else 'Never Used'
                except Exception:
                    key['LastUsedDate'] = 'Unknown'
                keys.append(key)
    except iam.exceptions.NoSuchEntityException:
        # User might have been deleted between listing and this call – skip.
        pass
    return keys


def main():
    # Optional filter pattern from command line
    filter_pattern = sys.argv[1] if len(sys.argv) > 1 else None

    # Get all users
    all_users = list_all_users()

    # Apply username filter if provided
    if filter_pattern:
        try:
            regex = re.compile(filter_pattern)
            all_users = [u for u in all_users if regex.search(u)]
        except re.error:
            print(f"Invalid regex pattern: {filter_pattern}", file=sys.stderr)
            sys.exit(1)

    # Prepare table data
    table_data = []
    for user in all_users:
        keys = get_access_keys(user)
        for key in keys:
            key_id = key['AccessKeyId']
            status = key['Status']          # 'Active' or 'Inactive'
            create_date = key['CreateDate'].isoformat()
            age = get_age_days(create_date)
            last_used = key['LastUsedDate']
            table_data.append([user, key_id, status, create_date, age, last_used])

    # Print table using tabulate
    headers = ["User", "AccessKeyId", "Status", "CreateDate", "Age(days)", "LastUsed"]
    if table_data:
        print(tabulate(table_data, headers=headers, tablefmt="grid"))
    else:
        print("No IAM users found (or none matched the filter).")


if __name__ == "__main__":
    main()
