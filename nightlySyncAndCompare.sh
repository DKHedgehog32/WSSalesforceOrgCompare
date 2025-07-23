#!/bin/sh

# === CONFIG ===
SOURCE_BRANCH="ws-production"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
REPORT_DIR="nightly-reports"
PACKAGE_XML_PATH="manifest/package.xml"

# Define parallel arrays for branches and org aliases
BRANCHES="ws-production ws-uat ws-newdev"
ALIASES="WSPRODUCTION WSUAT WSNEWDEV"

# === PREP ===
mkdir -p "$REPORT_DIR"
echo "📦 Fetching all latest branches..."
git fetch origin

# === STEP 1–3: Sync metadata from each org ===
i=1
for BRANCH in $BRANCHES; do
  # Get matching alias using set and shift
  set -- $ALIASES
  j=1
  for ALIAS in "$@"; do
    if [ $i -eq $j ]; then break; fi
    j=$((j + 1))
  done

  echo "🔄 [$BRANCH] Switching to branch and pulling latest..."
  git checkout "$BRANCH" || exit 1
  git pull origin "$BRANCH"

  echo "📥 [$ALIAS] Retrieving metadata using: $PACKAGE_XML_PATH"
  sfdx force:source:retrieve -u "$ALIAS" -x "$PACKAGE_XML_PATH"

  echo "💾 [$BRANCH] Committing changes..."
  git add .
  if git diff --cached --quiet; then
    echo "✅ No changes to commit on $BRANCH"
  else
    git commit -m "🔄 Nightly sync from $ALIAS on $TIMESTAMP"
    git push origin "$BRANCH"
  fi

  i=$((i + 1))
done

# === STEP 4–5: Compare production to each of the others ===
for TARGET_BRANCH in ws-uat ws-newdev; do
  echo "🔍 Comparing $SOURCE_BRANCH → $TARGET_BRANCH..."
  git checkout "$SOURCE_BRANCH" && git pull origin "$SOURCE_BRANCH"
  git checkout "$TARGET_BRANCH" && git pull origin "$TARGET_BRANCH"
  git checkout "$SOURCE_BRANCH"

  OUTPUT_CSV="$REPORT_DIR/missing-in-${TARGET_BRANCH}-vs-${SOURCE_BRANCH}-$TIMESTAMP.csv"
  echo "Missing File Path,Status" > "$OUTPUT_CSV"

  git diff --name-status "$TARGET_BRANCH..$SOURCE_BRANCH" | grep "^A" | while read -r line; do
    FILE_PATH=$(echo "$line" | awk '{print $2}')
    echo "$FILE_PATH,Present in Production only" >> "$OUTPUT_CSV"
  done

  echo "✅ Report saved: $OUTPUT_CSV"
done

echo "🎉 All metadata synced and comparisons complete!"