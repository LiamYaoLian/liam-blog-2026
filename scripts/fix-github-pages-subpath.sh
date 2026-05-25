#!/usr/bin/env bash
set -euo pipefail

# Blunix theme hardcodes root-absolute asset paths (/css, /fonts, etc.).
# GitHub Pages project sites are served from a subpath (/repo-name/).
BASE_URL="${1:-}"
SUBPATH="$(echo "$BASE_URL" | sed -E 's|https?://[^/]+||')"
SUBPATH="${SUBPATH%/}"

if [ -z "$SUBPATH" ]; then
  echo "No subpath detected; skipping asset path fix."
  exit 0
fi

echo "Rewriting root-absolute asset paths for subpath: ${SUBPATH}"
MARKER="__SUBPATH__"

if sed --version 2>/dev/null | grep -q GNU; then
  SED=(sed -i)
else
  SED=(sed -i '')
fi

fix_file() {
  "${SED[@]}" \
    -e "s|=\"${SUBPATH}/|=\"${MARKER}|g" \
    -e "s|url(\"${SUBPATH}/|url(\"${MARKER}|g" \
    -e "s|url('${SUBPATH}/|url('${MARKER}|g" \
    -e "s|href=${SUBPATH}/|href=${MARKER}|g" \
    -e "s|src=${SUBPATH}/|src=${MARKER}|g" \
    -e "s|=\"/|=\"${SUBPATH}/|g" \
    -e "s|url(\"/|url(\"${SUBPATH}/|g" \
    -e "s|url('/|url('${SUBPATH}/|g" \
    -e "s|href=/|href=${SUBPATH}/|g" \
    -e "s|src=/|src=${SUBPATH}/|g" \
    -e "s|=\"${MARKER}|=\"${SUBPATH}/|g" \
    -e "s|url(\"${MARKER}|url(\"${SUBPATH}/|g" \
    -e "s|url('${MARKER}|url('${SUBPATH}/|g" \
    -e "s|href=${MARKER}|href=${SUBPATH}/|g" \
    -e "s|src=${MARKER}|src=${SUBPATH}/|g" \
    "$1"
}

while IFS= read -r -d '' file; do
  fix_file "$file"
done < <(find public -type f \( -name '*.html' -o -name '*.css' -o -name '*.js' \) -print0)
