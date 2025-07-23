#!/bin/bash

# Compare from UAT to NewDev
SOURCE_BRANCH="ws-uat"
TARGET_BRANCH="ws-newdev"
OUTPUT_CSV="missing-in-${TARGET_BRANCH}-vs-${SOURCE_BRANCH}.csv"

# Fetch latest from remote
git fetch origin

# Make sure both branches are up-to-date
git checkout $SOURCE_BRANCH && git pull origin $SOURCE_BRANCH
git checkout $TARGET_BRANCH && git pull origin $TARGET_BRANCH

# Switch back to source branch for comparison
git checkout $SOURCE_BRANCH

# Initialize CSV
echo "Missing File Path,Status" > "$OUTPUT_CSV"

# Find files that exist in SOURCE but not in TARGET
git diff --name-status $TARGET_BRANCH..$SOURCE_BRANCH | grep "^A" | while read -r line; do
  file_path=$(echo $line | awk '{print $2}')
  echo "$file_path,Present in UAT only" >> "$OUTPUT_CSV"
done

echo "✅ Done! Missing files report saved as: $OUTPUT_CSV"