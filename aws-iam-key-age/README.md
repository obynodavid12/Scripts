# AWS IAM Access Key Reporting Scripts

## Prerequisites

Install the required Python package:

```bash
pip install tabulate
```

---

# iam_key_report.py

Generate an IAM access key report with optional filtering, age limits, inactive keys, and CSV export.

## Command Format

```bash
python3 iam_key_report.py [-h] \
    [--filter FILTER] \
    [--min-age MIN_AGE] \
    [--max-age MAX_AGE] \
    [--profile PROFILE] \
    [--include-inactive] \
    [--csv CSV]
```

## Example

```bash
python3 iam_key_report.py \
    --filter xyz \
    --min-age 0 \
    --max-age 2000 \
    --include-inactive \
    --csv iam.csv
```

---

# iam_keys_report.py

Generate a detailed IAM access key report with support for wildcard, regex, prefix, and partial username matching.

## Command Format

```bash
python3 iam_keys_report.py [-h] \
    [--name NAME] \
    [--pattern PATTERN] \
    [--prefix PREFIX] \
    [--filter FILTER] \
    [--contains CONTAINS] \
    [--min-age MIN_AGE] \
    [--max-age MAX_AGE] \
    [--profile PROFILE] \
    [--csv CSV]
```

## Examples

### Regex pattern

```bash
python3 iam_keys_report.py \
    --pattern "abc-.*" \
    --min-age 0 \
    --max-age 2000
```

### Partial username match

```bash
python3 iam_keys_report.py \
    --contains "obi-xyz" \
    --min-age 0 \
    --max-age 2000
```

### Match multiple username fragments

```bash
python3 iam_keys_report.py \
    --contains "abc-obi-xyz,obi-xyz,xyz-com-user" \
    --min-age 0 \
    --max-age 2000 \
    --csv iam_keys.csv
```

### Only users containing "xyz-com-user"

```bash
python3 iam_keys_report.py \
    --contains "xyz-com-user" \
    --min-age 90 \
    --max-age 365
```

### Combine prefix and partial match

```bash
python3 iam_keys_report.py \
    --prefix "obi-" \
    --contains "abc-xyz-com" \
    --min-age 180 \
    --max-age 1000
```

### Wildcard pattern

```bash
python3 iam_keys_report.py \
    --pattern "abc-*" \
    --min-age 0 \
    --max-age 2000
```

---

# iam-check.py

Display IAM users and access key information using regex filters.

## All users

```bash
python3 iam-check.py
```

## Users with a hyphen in the username

```bash
python3 iam-check.py ".*-.*"
```

## Users starting with "dev-"

```bash
python3 iam-check.py "^dev-.*"
```

## Users starting with "abc-"

```bash
python3 iam-check.py "^abc-.*"
```

---

# check-iam-keys.py

Report IAM access keys using regular expression filtering.

## Default credentials (no filter)

```bash
python3 check-iam-keys.py
```

## Usernames containing a hyphen

```bash
python3 check-iam-keys.py ".*-.*"
```

## Usernames ending with "-prod"

```bash
python3 check-iam-keys.py ".*-prod$"
```

## Usernames starting with "abc-"

```bash
python3 check-iam-keys.py "^abc-.*"
```

---

# check.py

Generate an IAM key report using regex and age filters.

## Command

```bash
python3 check.py \
    --pattern "abc-*" \
    --min-age 0 \
    --max-age 2000
```

---

# Common Filter Examples

| Filter Type | Example |
|-------------|---------|
| Partial username | `--contains "obi-xyz"` |
| Multiple partial matches | `--contains "abc-obi-xyz,obi-xyz,xyz-com-user"` |
| Prefix | `--prefix "obi-"` |
| Regex | `--pattern "^abc-.*"` |
| Wildcard | `--pattern "abc-*"` |
| Age range | `--min-age 90 --max-age 365` |
| Export CSV | `--csv report.csv` |
| Include inactive keys | `--include-inactive` |

---

## Notes

- All scripts use your configured AWS credentials or the specified AWS CLI profile (`--profile`).
- Username matching is case-insensitive when using `--contains`.
- Reports can optionally be exported to CSV using the `--csv` option.
- Age values are calculated in days from the access key creation date.
- Some scripts also display access key status and last-used information.
