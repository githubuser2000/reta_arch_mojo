#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-prompt-language-catalog.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
PYTHON=${RETA_PYTHON-}
if [ -z "$PYTHON" ]; then
    if [ -x "$ROOT/.venv/bin/python" ]; then
        PYTHON="$ROOT/.venv/bin/python"
    else
        PYTHON=$(command -v python3)
    fi
fi
RETA_PROMPT_CATALOG_OUT="$TMP" PYTHONHASHSEED=0 \
    "$PYTHON" scripts/generate_prompt_nested_catalog.py >/dev/null
for name in \
    prompt_nested_completion.tsv \
    prompt_command_aliases.tsv \
    prompt_shortcut_replacements.tsv \
    prompt_numeric_shortcuts.tsv \
    prompt_vocabulary.tsv
do
    cmp "assets/$name" "$TMP/$name"
done
printf '%s\n' 'Mehrsprachiger Prompt-Katalog ist reproduzierbar.'
