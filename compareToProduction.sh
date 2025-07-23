#!/bin/bash

# Define branches
SOURCE_BRANCH="ws-production"
TARGET_BRANCH="ws-uat"
OUTPUT_CSV="compare-${TARGET_BRANCH}-vs-${SOURCE_BRANCH}.csv"

# Checkout both branches to make sure we have the latest
git fetch origin
git checkout $TARGET_BRANCH
git pull origin $TARGET_BRANCH
git checkout $SOURCE_BRANCH
git pull origin $SOURCE_BRANCH

# Run git diff and create CSV output
echo "File Path,Change Type" > "$OUTPUT_CSV"

# Loop through diffed files
git diff --name-status $SOURCE_BRANCH $TARGET_BRANCH | while read -r line; do
  change_type=$(echo $line | awk '{print $1}')
  file_path=$(echo $line | awk '{print $2}')

  case "$change_type" in
    A) label="Added" ;;
    M) label="Modified" ;;
    D) label="Deleted" ;;
    *) label="Other" ;;
  esac

  echo "$file_path,$label" >> "$OUTPUT_CSV"
done

echo "✅ Comparison complete. CSV saved as $OUTPUT_CSV"