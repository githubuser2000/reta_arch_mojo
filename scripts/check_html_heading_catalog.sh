#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-html-heading-catalog.$$
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp assets/html_heading_catalog.tsv "$TMP"
python3 scripts/generate_html_heading_catalog.py >/dev/null
cmp "$TMP" assets/html_heading_catalog.tsv
printf '%s\n' 'Dynamischer HTML-Überschriftenkatalog reproduzierbar.'
