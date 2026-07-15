#!/usr/bin/env python3

"""
AWS IAM Access Key Age Report

Finds IAM access keys (Active + Inactive) within a specified age range.

Features
--------
- Filter by substrings in username (e.g. abc-xyz-com, obi-abc, xyz-com-users)
- IAM user wildcard filtering (--name)
- Regex filtering (--pattern)
- Prefix filtering (--prefix)
- Pagination support
- Access key age calculation
- Status + Last Used
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
        "Example: abc-a10h-dcs-xyz-gom-users-*-*"
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
    "--contains",
    default="",
    help=(
        "Comma-separated substrings to match in IAM username. "
        "Example: abc-xyz-com,obi-abc,xyz-com-users"
    )
)

parser.add_argument(
    "--min-age",
    type=int,
    default=1,
    help="Minimum key age in days"
)

parser.add_argument(
    "--max-age",
    type=int,
    default=2000,
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
    logger.error(
        "Invalid username pattern: %s",
        e
    )
    sys.exit(1)

# Parse --contains into a list
contains_list = []
if args.contains:
    contains_list = [c.strip() for c in args.contains.split(",") if c.strip()]


def user_matches(username: str) -> bool:
    # --filter (single substring, case-insensitive)
    if args.filter:
        if args.filter.lower() not in username.lower():
            return False

    # --contains (multiple substrings, match ANY)
    if contains_list:
        if not any(sub in username for sub in contains_list):
            return False

    # --prefix
    if args.prefix:
        if not username.startswith(args.prefix):
            return False

    # --pattern / --name (regex)
    if not user_regex.match(username):
        return False

    return True


# --------------------------------------------------------
# AWS Session
# --------------------------------------------------------

try:
    if args.profile:
        session = boto3.Session(
            profile_name=args.profile
        )
    else:
        session = boto3.Session()

    iam = session.client("iam")

except Exception as e:
    logger.error(
        "AWS session failed: %s",
        e
    )
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

            if not user_matches(username):
                continue

            logger.info(
                "Checking IAM user: %s",
                username
            )

            # -----------------------------
            # Get Access Keys
            # -----------------------------

            for key_page in keys_paginator.paginate(
                UserName=username
            ):

                for key in key_page["AccessKeyMetadata"]:

                    # Include both Active and Inactive keys
                    # (remove this if you only want Active)
                    # if key["Status"] != "Active":
                    #     continue

                    create_date = key["CreateDate"]

                    age = (today - create_date).days

                    if age < args.min_age or age > args.max_age:
                        continue

                    # Get Last Used
                    last_used = "Never"
                    try:
                        lu = iam.get_access_key_last_used(
                            AccessKeyId=key["AccessKeyId"]
                        )["AccessKeyLastUsed"]
                        if lu.get("LastUsedDate"):
                            last_used = lu["LastUsedDate"].strftime("%Y-%m-%d")
                    except ClientError:
                        pass

                    results.append(
                        [
                            username,
                            key["AccessKeyId"],
                            key["Status"],
                            create_date.strftime("%Y-%m-%d"),
                            age,
                            last_used,
                        ]
                    )

except ClientError as e:
    logger.error(
        "AWS API error: %s",
        e
    )
    sys.exit(2)


# --------------------------------------------------------
# Sort Results (oldest first)
# --------------------------------------------------------

results.sort(
    key=lambda x: x[4],
    reverse=True
)


# --------------------------------------------------------
# Display Results
# --------------------------------------------------------

if results:
    print(
        "\n"
        + tabulate(
            results,
            headers=[
                "IAM User",
                "Access Key",
                "Status",
                "Created",
                "Age (Days)",
                "Last Used",
            ],
            tablefmt="grid",
        )
    )
else:
    print(
        "\nNo matching IAM access keys found."
    )


# --------------------------------------------------------
# CSV Export
# --------------------------------------------------------

if args.csv and results:

    try:
        with open(
            args.csv,
            "w",
            newline=""
        ) as f:

            writer = csv.writer(f)

            writer.writerow(
                [
                    "IAM User",
                    "Access Key",
                    "Status",
                    "Created",
                    "Age Days",
                    "Last Used",
                ]
            )

            writer.writerows(results)

        logger.info(
            "CSV report written: %s",
            args.csv
        )

    except Exception as e:

        logger.error(
            "CSV write failed: %s",
            e
        )


# --------------------------------------------------------
# Summary
# --------------------------------------------------------

logger.info(
    "Total keys found: %s",
    len(results)
)
