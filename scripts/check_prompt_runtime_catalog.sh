#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ -n "${RETA_PYTHON:-}" ]; then
    PYTHON=$RETA_PYTHON
elif [ -x "$ROOT/.venv/bin/python" ]; then
    PYTHON="$ROOT/.venv/bin/python"
else
    PYTHON=python3
fi
TMP=${TMPDIR:-/tmp}/reta-prompt-runtime-catalog.$$.mojo
PREFIX_TMP=${TMPDIR:-/tmp}/reta-prompt-prefix-catalog.$$.mojo
trap 'rm -f "$TMP" "$PREFIX_TMP"' EXIT HUP INT TERM
PYTHONHASHSEED=0 "$PYTHON" tools/generate_prompt_runtime_catalog.py --output "$TMP" --prefix-output "$PREFIX_TMP" >/dev/null
if ! cmp src/reta_mojo/prompt_runtime_catalog.mojo "$TMP"; then
    diff -u src/reta_mojo/prompt_runtime_catalog.mojo "$TMP" || true
    exit 1
fi
if ! cmp src/reta_mojo/prompt_prefix_catalog.mojo "$PREFIX_TMP"; then
    diff -u src/reta_mojo/prompt_prefix_catalog.mojo "$PREFIX_TMP" || true
    exit 1
fi
printf '%s\n' 'Prompt-Runtime- und Präfixkatalog sind reproduzierbar (5 Sprachen).'

