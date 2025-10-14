#!/usr/bin/env bash
# set -euo pipefail

BASE_URL=${1:-"http://localhost:8080"}
PAGES_FILE="${2:-"pages.txt"}"
HEADERS_FILE="${3:-}"
OUTDIR="${4:-./scan_headers}"
search="SECOND STEP"
diffs=0
matches=0

mkdir -p "$OUTDIR"/html "$OUTDIR"/diffs

usage() {
  cat <<EOF
Usage: $0 BASE_URL PAGES_FILE [HEADERS_FILE] OUTPUT_DIR
  BASE_URL   e.g. http://localhost:8080
  PAGES_FILE one page per line, e.g. "/?page=b7e44c7..." or "/index.html"
  HEADERS_FILE optional, one header per line, e.g. "Referer: https://www.nsa.gov/"
             If omitted a default set is used (including Referer).
  OUTPUT_DIR directory to store outputs (created if missing)
Example:
  $0 http://localhost:8080 pages_list.txt headers_list.txt results
EOF
  exit 1
}

if [[ -z "$BASE_URL" || -z "$PAGES_FILE" ]]; then
  usage
fi

# default headers (if no HEADERS_FILE provided)
if [ -z "$HEADERS_FILE" ] || [ ! -f "$HEADERS_FILE" ]; then
  headers=( \
    "Referer: https://www.nsa.gov/" \
    "Origin: https://www.nsa.gov/" \
    # "X-Forwarded-For: 127.0.0.1" \
    # "User-Agent: friendly-bot/1.0" \
    # "" \
  )
else
  mapfile -t headers < "$HEADERS_FILE"
fi

# CSV output
CSV="$OUTDIR/results.csv"
printf 'timestamp,base_url,page,header,matched,diff,match_snippet\n' > "$CSV"

# helper to sanitize filenames
sanitize() {
  printf '%s' "$1" | sed 's/[^A-Za-z0-9._-]/_/g' | cut -c1-120
}

while IFS= read -r page || [ -n "$page" ]; do
  # skip empty or comment lines
  [[ -z "$page" || "$page" =~ ^# ]] && continue

  # build URL (allow pages like "/?page=..." or "path/page.html")
  if [[ "$page" == /* ]]; then
    url="${BASE_URL%/}$page"
  else
    url="${BASE_URL%/}/$page"
  fi

  # base response (no extra header) saved once per page for diffs
  base_file="$OUTDIR/html/$(sanitize "$page")__base.html"
  if [ ! -f "$base_file" ]; then
    curl -s -L "$url" -o "$base_file" || true
  fi

  for header in "${headers[@]}"; do
    # prepare header argument for curl
    hdr_arg=()
    if [ -n "$header" ]; then
      hdr_arg=(-H "$header")
    fi

    name="$(sanitize "$page")__$(sanitize "$header")"
    out_html="$OUTDIR/html/${name}.html"

    # fetch page
    curl -s -L "${hdr_arg[@]}" "$url" -o "$out_html" || true

    # diff with base to highlight changes
    diff_file="$OUTDIR/diffs/${name}.diff"
    diff -u "$base_file" "$out_html" > "$diff_file" || true
    diff_res="no"
    if [ $(wc -c < $diff_file) -ne 0 ]; then
      diffs=$((diffs + 1))
      diff_res="yes"
      diff -u "$base_file" "$out_html" 
    fi

    # search for "SECOND STEP" (case-insensitive), show line and context
    match=$(grep -i -n -m1 "$search" "$out_html" || true)
    matched="no"
    snippet=""
    if [ -n "$match" ]; then
      matched="yes"
      matches=$((matches + 1))
      # show the matched line and 2 lines of context
      lineno=${match%%:*}
      snippet=$(sed -n "$((lineno-2)),$((lineno+2))p" "$out_html" | tr '\n' ' ' | sed 's/"/\\"/g')
    fi

    # timestamp in ISO format
    ts=$(date -Iseconds)

    # append CSV row (quote fields)
    printf '%s,"%s","%s","%s","%s","%s","%s"\n' \
      "$ts" "$BASE_URL" "$page" "$header" "$matched" "$diff_res" "$snippet" \
      >> "$CSV"

    # optionally print live progress
    echo "[$ts] tested page=$page header='${header}' matched=${matched}"
  done
done < "$PAGES_FILE"
rm -rf $OUTDIR/diffs
rm -rf $OUTDIR/html

echo ""
echo "Search: $search, Matchs: $matches"
echo "Diffs: $diffs"
echo "Read csv with: "
echo "xdg-open $CSV"
