#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/prompt_runtime_contract_probe.mojo -o target/tests/prompt_runtime_contract_probe
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
TMP=${TMPDIR:-/tmp}/reta-prompt-runtime.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
for language in deutsch english vietnamese chinese korean; do
    PYTHONHASHSEED=0 "$PYTHON" scripts/prompt_runtime_reference.py "$language" > "$TMP/$language.python"
    target/tests/prompt_runtime_contract_probe "$language" > "$TMP/$language.mojo"
    if ! cmp "$TMP/$language.python" "$TMP/$language.mojo"; then
        diff -u "$TMP/$language.python" "$TMP/$language.mojo" || true
        exit 1
    fi
    printf '%-12s prompt-runtime contract byte-identical\n' "$language"
done
printf '%s\n' 'Prompt-Runtime-Vertrag ist in 5 Sprachen bytegleich.'
