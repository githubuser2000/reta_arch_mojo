#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-schema-catalog.$$.mojo
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp src/reta_mojo/schema_catalog.mojo "$TMP"
python3 tools/generate_schema_catalog.py >/dev/null
cmp "$TMP" src/reta_mojo/schema_catalog.mojo
printf '%s\n' 'Großer Parameterschema-Katalog ist reproduzierbar.'
