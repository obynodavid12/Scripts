#!/usr/bin/env python3
import argparse,boto3,csv,logging,sys
from datetime import datetime,timezone
from botocore.exceptions import ClientError
from tabulate import tabulate

logging.basicConfig(level=logging.INFO,format="%(asctime)s %(levelname)s %(message)s")
log=logging.getLogger(__name__)

p=argparse.ArgumentParser(description="IAM Access Key Age Report")
p.add_argument("--filter",default="",help="Case-insensitive partial IAM username filter")
p.add_argument("--min-age",type=int,default=0)
p.add_argument("--max-age",type=int,default=99999)
p.add_argument("--profile")
p.add_argument("--include-inactive",action="store_true")
p.add_argument("--csv")
args=p.parse_args()

session=boto3.Session(profile_name=args.profile) if args.profile else boto3.Session()
iam=session.client("iam")
today=datetime.now(timezone.utc)
rows=[]
users_scanned=0
matched_users=0
keys_found=0

try:
    up=iam.get_paginator("list_users")
    kp=iam.get_paginator("list_access_keys")
    flt=args.filter.lower()
    for page in up.paginate():
        for user in page["Users"]:
            users_scanned+=1
            uname=user["UserName"]
            if flt and flt not in uname.lower():
                continue
            matched_users+=1
            for kpage in kp.paginate(UserName=uname):
                for key in kpage["AccessKeyMetadata"]:
                    if not args.include_inactive and key["Status"]!="Active":
                        continue
                    age=(today-key["CreateDate"]).days
                    if age<args.min_age or age>args.max_age:
                        continue
                    last_used="Never"
                    try:
                        lu=iam.get_access_key_last_used(AccessKeyId=key["AccessKeyId"])["AccessKeyLastUsed"]
                        if lu.get("LastUsedDate"):
                            last_used=lu["LastUsedDate"].strftime("%Y-%m-%d")
                    except ClientError:
                        pass
                    rows.append([
                        uname,
                        key["AccessKeyId"],
                        key["Status"],
                        key["CreateDate"].strftime("%Y-%m-%d"),
                        age,
                        last_used
                    ])
                    keys_found+=1
except ClientError as e:
    log.error(e)
    sys.exit(2)

rows.sort(key=lambda r:r[4],reverse=True)
headers=["IAM User","Access Key","Status","Created","Age (Days)","Last Used"]
if rows:
    print(tabulate(rows,headers=headers,tablefmt="grid"))
else:
    print("No matching IAM access keys found.")

print(f"\nUsers scanned : {users_scanned}")
print(f"Users matched : {matched_users}")
print(f"Keys found    : {keys_found}")

if args.csv and rows:
    with open(args.csv,"w",newline="") as f:
        w=csv.writer(f)
        w.writerow(headers)
        w.writerows(rows)
    log.info("CSV written to %s",args.csv)
