#!/bin/sh

# === CONFIG ===
SOURCE_BRANCH="ws-production"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
REPORT_DIR="nightly-reports"
PACKAGE_XML_PATH="manifest/package.xml"
mkdir -p "$REPORT_DIR"

# Parallel arrays: branches & aliases
BRANCHES="ws-production ws-uat ws-newdev"
ALIASES="WSPRODUCTION WSUAT WSNEWDEV"

# === STEP 1: Sync metadata from each org ===
i=1
for BRANCH in $BRANCHES; do
  # Get matching alias
  set -- $ALIASES
  j=1
  for ALIAS in "$@"; do
    if [ $i -eq $j ]; then break; fi
    j=$((j + 1))
  done

  echo "🔄 [$BRANCH] Checking out branch and pulling latest..."
  git checkout "$BRANCH" || exit 1
  git pull origin "$BRANCH"

  echo "📥 [$ALIAS] Retrieving metadata..."
  sfdx force:source:retrieve -u "$ALIAS" -x "$PACKAGE_XML_PATH"

  echo "💾 [$BRANCH] Committing any changes..."
  git add .
  if git diff --cached --quiet; then
    echo "✅ No changes to commit for $BRANCH"
  else
    git commit -m "🔄 Nightly sync from $ALIAS on $TIMESTAMP"
    git push origin "$BRANCH"
  fi

  i=$((i + 1))
done

# === STEP 2: Compare UAT and NewDev to Production ===
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

# === STEP 3: Email reports via iCloud SMTP ===
SMTP_SERVER="smtp.mail.me.com"
SMTP_PORT="587"
FROM_EMAIL="denniskristoffers@icloud.com"
TO_EMAILS="Dennis.van.Musschenbroek@woonstadrotterdam.nl,Dave.Godlieb@woonstadrotterdam.nl"
SUBJECT="Salesforce Metadata Report - $TIMESTAMP"
BODY="Hi Dennis and Dave,\n\nAttached are the nightly metadata diff reports showing what exists in Production but is missing from UAT and NewDev.\n\n– Salesforce CI/CD Monitor"

# Load credentials securely
. "$HOME/Documents/vscode/.smtp-creds.conf"

sendemail -f "$FROM_EMAIL" \
          -t "$TO_EMAILS" \
          -u "$SUBJECT" \
          -m "$BODY" \
          -s "$SMTP_SERVER":"$SMTP_PORT" \
          -xu "$USERNAME" -xp "$PASSWORD" \
          -o tls=yes \
          -a "$REPORT_DIR/missing-in-ws-uat-vs-ws-production-$TIMESTAMP.csv" \
             "$REPORT_DIR/missing-in-ws-newdev-vs-ws-production-$TIMESTAMP.csv"

echo "📧 Email sent to: $TO_EMAILS"
echo "🎉 All metadata synced, compared, and reports delivered."