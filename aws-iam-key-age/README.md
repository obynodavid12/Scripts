# Install tabulate if not already
pip install tabulate

# iam_key_report.py
# Command Format
python3 iam_key_report.py [-h] [--filter FILTER] [--min-age MIN_AGE] [--max-age MAX_AGE] [--profile PROFILE] [--include-inactive] [--csv CSV]

# Example
python3 iam_key_report.py --filter xyz --min-age 0 --max-age 2000 --include-inactive --csv iam.csv

# iam_keys_report.py
# Command format
python3 iam_keys_report.py [-h] [--name NAME] [--pattern PATTERN] [--prefix PREFIX] [--filter FILTER] [--min-age MIN_AGE] [--max-age MAX_AGE] [--profile PROFILE] [--csv CSV]
python3 iam_key_report.py --pattern abc-obi --min-age 0 --max-age 2000
python3 iam_keys_report.py --contains obi-xyz --min-age 0 --max-age 2000

python3 iam_keys_report.py \
  --contains "abc-obi-xyz,obi-xyz,xyz-com-user" \
  --min-age 0 \
  --max-age 2000 \
  --csv iam_keys.csv

  # Only users with "xyz-com-users" in the name
python3 iam_keys_report.py --contains "xyz-com-user" --min-age 90 --max-age 365

# Combine prefix + contains
python3 iam_keys_report.py --prefix "obi-" --contains "abc-xyz-com" --min-age 180 --max-age 1000

python3 iam_keys_report.py --pattern abc-* --min-age 0 --max-age 2000

python3 iam_keys_report.py --contains obi-xyz --min-age 0 --max-
age 2000

python3 iam_keys_report.py \
  --contains "abc-obi-xyz,obi-xyz,xyz-com-user" \
  --min-age 0 \
  --max-age 2000 \
  --csv iam_keys.csv

# iam-check.py
# All users
python3 iam-check.py

# Only users with hyphen in their name
python3 iam-check.py ".*-.*"

# Users whose name starts with "dev-"
python3 iam-check.py "^dev-.*"

python3 iam-check.py "^abc-.*"

python3 check-iam-keys.py "^abc-.*"

# Run with default credentials (no filter)
python check-iam-keys.py

# Filter usernames containing a hyphen
python check-iam-keys.py ".*-.*"

# Filter usernames ending with "-prod"
python check-iam-keys.py ".*-prod$"

# check.py
python3 check.py --pattern abc-* --min-age 0 --max-age 2000
