#!/usr/bin/env python3

"""
AWS IAM Access Key Age Report(cody)

Finds ACTIVE IAM access keys older than a specified age.

Features
--------
- IAM user wildcard filtering
- Regex filtering
- Prefix filtering
- Pagination support
- Active keys only
- Access key age calculation
- CSV export
- Production logging
"""

import argparse
import boto3
import csv
import logging
import re
import sys
from datetime import datetime, timezone
from botocore.exceptions import ClientError
from tabulate import tabulate

# --------------------------------------------------------
# Logging
# --------------------------------------------------------

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

logger = logging.getLogger(__name__)

# --------------------------------------------------------
# Arguments
# --------------------------------------------------------

parser = argparse.ArgumentParser(
    description="AWS IAM Access Key Age Report"
)

parser.add_argument(
    "--name",
    help=(
        "Wildcard IAM username pattern. "
        "Example: abc-xyz-com-* or obi-abc-* or xyz-com-users-* or abc-a10h-dcs-xyz-gom-users-*-*"
    )
)

parser.add_argument(
    "--pattern",
    default=".*",
    help="Regex IAM username filter"
)

parser.add_argument(
    "--prefix",
    help="IAM username prefix filter"
)

parser.add_argument(
    "--filter",
    default="",
    help="Filter IAM usernames by partial name (case-insensitive)"
)

parser.add_argument(
    "--min-age",
    type=int,
    default=365,
    help="Minimum key age in days"
)

parser.add_argument(
    "--max-age",
    type=int,
    default=99999,
    help="Maximum key age in days"
)

parser.add_argument(
    "--profile",
    help="AWS CLI profile name"
)

parser.add_argument(
    "--csv",
    help="CSV output filename"
)

args = parser.parse_args()

# --------------------------------------------------------
# Build User Filter
# --------------------------------------------------------

try:
    if args.name:
        # Convert wildcard (*) to regex
        regex_pattern = (
            "^"
            + re.escape(args.name).replace(r"\*", ".*")
            + "$"
        )
    else:
        regex_pattern = args.pattern

    user_regex = re.compile(regex_pattern)

except re.error as e:
    logger.error("Invalid username pattern: %s", e)
    sys.exit(1)

# --------------------------------------------------------
# AWS Session
# --------------------------------------------------------

try:
    if args.profile:
        session = boto3.Session(profile_name=args.profile)
    else:
        session = boto3.Session()

    iam = session.client("iam")

except Exception as e:
    logger.error("AWS session failed: %s", e)
    sys.exit(1)

today = datetime.now(timezone.utc)
results = []

# --------------------------------------------------------
# Fetch IAM Users
# --------------------------------------------------------

logger.info("Fetching IAM users...")

try:
    users_paginator = iam.get_paginator("list_users")
    keys_paginator = iam.get_paginator("list_access_keys")

    for page in users_paginator.paginate():
        for user in page["Users"]:
            username = user["UserName"]

            # -----------------------------
            # Prefix filter (fast)
            # -----------------------------
            if args.prefix and not username.startswith(args.prefix):
                continue

            # -----------------------------
            # Regex / wildcard filter
            # -----------------------------
            if not user_regex.match(username):
                continue

            logger.info("Checking IAM user: %s", username)

            # -----------------------------
            # Get Access Keys
            # -----------------------------
            for key_page in keys_paginator.paginate(UserName=username):
                for key in key_page["AccessKeyMetadata"]:
                    # Only active keys
                    if key["Status"] != "Active":
                        continue

                    create_date = key["CreateDate"]
                    last_used_date = key.get("LastUsedDate", "Never Used")
                    age = (today - create_date).days

                    if age < args.min_age or age > args.max_age:
                        continue

                    results.append([
                        username,
                        key["AccessKeyId"],
                        create_date.strftime("%Y-%m-%d"),
                        last_used_date.strftime("%Y-%m-%d") if last_used_date != "Never Used" else last_used_date,
                        age,
                        key["Status"]
                    ])

except ClientError as e:
    logger.error("AWS API error: %s", e)
    sys.exit(2)

# --------------------------------------------------------
# Sort Results
# --------------------------------------------------------

results.sort(key=lambda x: x[4], reverse=True)

# --------------------------------------------------------
# Display Results
# --------------------------------------------------------

if results:
    print(
        "\n" + tabulate(
            results,
            headers=[
                "IAM User",
                "Access Key",
                "Created",
                "Last Used",
                "Age (Days)",
                "Status"
            ],
            tablefmt="grid"
        )
    )
else:
    print("\nNo matching IAM access keys found.")

# --------------------------------------------------------
# CSV Export
# --------------------------------------------------------

if args.csv and results:
    try:
        with open(args.csv, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "IAM User",
                "Access Key",
                "Created",
                "Last Used",
                "Age Days",
                "Status"
            ])
            writer.writerows(results)

        logger.info("CSV report written: %s", args.csv)

    except Exception as e:
        logger.error("CSV write failed: %s", e)

# --------------------------------------------------------
# Summary
# --------------------------------------------------------

logger.info("Total expired/old active keys found: %s", len(results))
