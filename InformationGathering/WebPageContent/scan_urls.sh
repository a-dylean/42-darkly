#!/usr/bin/env bash
# set -euo pipefail

# Usage:
#   ./referer-diff-scan.sh http://localhost:8080 "https://www.nsa.gov/" ./output_dir
#
# Example:
#   ./referer-diff-scan.sh http://localhost:8080 "https://www.nsa.gov/" ./scan_results

BASE_URL=${1:-"http://localhost:8080"}
OUT_DIR=${2:-"./scan_urls"}
WGET_LOG="${OUT_DIR}/wget_spider.log"
URLS_FILE="${OUT_DIR}/urls.txt"

# quick sanity
if [[ -z "$BASE_URL" ]]; then
  echo "Usage: $0 <base-url> <referer> <output-dir>"
  exit 2
fi

mkdir -p "$OUT_DIR" 

echo "[*] Crawling $BASE_URL (spidering) — this will populate $URLS_FILE ..."
# Crawl the site to discover URLs (wget spider mode)
# -r : recursive; -l 5 : up to depth 5 (adjust if needed); --no-parent prevents going above base
# -nv : less verbose; -o logfile
wget --spider -r -l 5 --no-parent -nv -o "$WGET_LOG" "$BASE_URL" 

# Extract http/https URLs from wget log, deduplicate
grep -oE 'http?://[^ ]+' "$WGET_LOG" | sed 's/[[:punct:]]$//' | sort -u > "$URLS_FILE"

# Ensure only URLs on the same host are tested (optional but safe)
BASE_HOST=$(echo "$BASE_URL" | sed -E 's#http?://([^/]+).*#\1#')
echo "[*] Filtering URLs to same host: $BASE_HOST"
grep -E "^http?://$BASE_HOST(/|$)" "$URLS_FILE" > "${URLS_FILE}.host"
mv "${URLS_FILE}.host" "$URLS_FILE"

echo "[*] Found $(wc -l < "$URLS_FILE") URLs to test. Listing saved in $URLS_FILE"
echo
echo "    - URL list: $URLS_FILE"
echo "    - wget log: $WGET_LOG"
