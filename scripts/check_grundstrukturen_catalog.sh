#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-grundstrukturen-catalog.$$
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp src/reta_mojo/grundstrukturen_catalog.mojo "$TMP"
python3 tools/generate_grundstrukturen_catalog.py >/dev/null
cmp "$TMP" src/reta_mojo/grundstrukturen_catalog.mojo
printf '%s\n' 'Grundstrukturen-Katalog ist reproduzierbar (2 × 151 Datensätze).'
