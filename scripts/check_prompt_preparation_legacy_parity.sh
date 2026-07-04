#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
PROBE=target/tests/prompt_preparation_legacy_snapshot_probe
"$MOJO" build -I src tests/prompt_preparation_legacy_snapshot_probe.mojo -o "$PROBE"
TMP=${TMPDIR:-/tmp}/reta-prompt-preparation-legacy.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
for language in deutsch english vietnamese chinese korean; do
    PYTHONHASHSEED=0 "$PYTHON" scripts/prompt_preparation_legacy_reference.py \
        "$language" > "$TMP/$language.python"
    "$ROOT/bin/mojo-runtime-exec" "$PROBE" "$language" > "$TMP/$language.mojo"
    if ! cmp "$TMP/$language.python" "$TMP/$language.mojo"; then
        diff -u "$TMP/$language.python" "$TMP/$language.mojo" || true
        exit 1
    fi
    printf '%-12s legacy prompt-preparation snapshot identical\n' "$language"
done
