#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-prompt-catalog.$$
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp src/reta_mojo/prompt_catalog.mojo "$TMP"
python3 scripts/generate_prompt_catalog.py >/dev/null
cmp "$TMP" src/reta_mojo/prompt_catalog.mojo
printf '%s\n' 'Promptkatalog ist reproduzierbar (388 Wörter).'
