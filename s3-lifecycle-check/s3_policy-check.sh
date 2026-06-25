#!/bin/bash

set -uo pipefail

ACTION="${1:-}"
BUCKET="${2:-}"

BASELINE_DIR="s3_baseline"
CURRENT_DIR="s3_current"

usage() {
    echo "Usage:"
    echo "  $0 backup  <bucket-name|all>"
    echo "  $0 compare <bucket-name|all>"
    echo
    echo "Examples:"
    echo "  $0 backup obi-test-1"
    echo "  $0 compare obi-test-1"
    echo "  $0 backup all"
    echo "  $0 compare all"
    exit 1
}

[ -z "$ACTION" ] && usage
[ -z "$BUCKET" ] && usage

capture_bucket() {

    local TARGET_DIR=$1
    local BUCKET_NAME=$2

    mkdir -p "${TARGET_DIR}/lifecycle"
    mkdir -p "${TARGET_DIR}/policies"

    echo "Collecting configuration for bucket: ${BUCKET_NAME}"

    aws s3api get-bucket-lifecycle-configuration \
        --bucket "${BUCKET_NAME}" \
        --output json \
        > "${TARGET_DIR}/lifecycle/${BUCKET_NAME}.json" 2>/dev/null || \
        echo '{}' > "${TARGET_DIR}/lifecycle/${BUCKET_NAME}.json"

    aws s3api get-bucket-policy \
        --bucket "${BUCKET_NAME}" \
        --query Policy \
        --output text \
        > "${TARGET_DIR}/policies/${BUCKET_NAME}.json" 2>/dev/null || \
        echo '{}' > "${TARGET_DIR}/policies/${BUCKET_NAME}.json"
}

get_bucket_list() {

    if [ "$BUCKET" = "all" ]; then
        aws s3api list-buckets \
            --query 'Buckets[].Name' \
            --output text
    else
        echo "$BUCKET"
    fi
}

backup() {

    mkdir -p "${BASELINE_DIR}"

    for bucket_name in $(get_bucket_list); do
        capture_bucket "${BASELINE_DIR}" "${bucket_name}"
    done

    echo
    echo "Baseline capture complete."
}

compare() {

    mkdir -p "${CURRENT_DIR}"

    for bucket_name in $(get_bucket_list); do

        echo
        echo "=================================================="
        echo "Checking bucket: ${bucket_name}"
        echo "=================================================="

        if [ ! -f "${BASELINE_DIR}/lifecycle/${bucket_name}.json" ]; then
            echo "No baseline found for ${bucket_name}"
            continue
        fi

        capture_bucket "${CURRENT_DIR}" "${bucket_name}"

        echo
        echo "Lifecycle Policy Comparison"
        echo "----------------------------------------"

        if diff -q \
            "${BASELINE_DIR}/lifecycle/${bucket_name}.json" \
            "${CURRENT_DIR}/lifecycle/${bucket_name}.json" >/dev/null; then
            echo "No lifecycle policy changes."
        else
            diff -u \
                "${BASELINE_DIR}/lifecycle/${bucket_name}.json" \
                "${CURRENT_DIR}/lifecycle/${bucket_name}.json"
        fi

        echo
        echo "Bucket Policy Comparison"
        echo "----------------------------------------"

        if diff -q \
            "${BASELINE_DIR}/policies/${bucket_name}.json" \
            "${CURRENT_DIR}/policies/${bucket_name}.json" >/dev/null; then
            echo "No bucket policy changes."
        else
            diff -u \
                "${BASELINE_DIR}/policies/${bucket_name}.json" \
                "${CURRENT_DIR}/policies/${bucket_name}.json"
        fi
    done

    echo
    echo "Comparison complete."
}

case "$ACTION" in
    backup)
        backup
        ;;
    compare)
        compare
        ;;
    *)
        usage
        ;;
esac
