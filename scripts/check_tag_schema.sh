#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-tag-schema.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
cp src/reta_mojo/tag_schema_catalog.mojo "$TMP/catalog.mojo"
cp tests/tag_schema_parity_constants.mojo "$TMP/constants.mojo"
python3 tools/generate_tag_schema.py >/dev/null
cmp "$TMP/catalog.mojo" src/reta_mojo/tag_schema_catalog.mojo
cmp "$TMP/constants.mojo" tests/tag_schema_parity_constants.mojo
printf '%s\n' 'Tag-Schema und vollständige Paritätsfingerprints sind reproduzierbar.'
