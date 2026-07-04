#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
PYTHON=${PYTHON_BIN:-$("$ROOT/scripts/find_test_python.sh")}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
OUT=${PROMPT_HISTORICAL_FAMILIES_OUT:-"$ROOT/target/tests/prompt_historical_families"}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-historical-families.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

if [[ ! -x "$PROMPT" ]]; then
    printf '%s\n' \
        "Fehlendes Produktionsbinary: $PROMPT" \
        "Bitte zuerst selbst kompilieren: scripts/build-all.sh" >&2
    exit 78
fi
RETA_REBUILD_COMMAND=scripts/build-all.sh \
    "$ROOT/scripts/check_mojo_binary_freshness.sh" "$PROMPT"

mkdir -p "$OUT" "$TMP/runtime/python_reference"
ln -s "$ROOT/assets" "$TMP/runtime/assets"
ln -s "$ROOT/python_reference/csv" "$TMP/runtime/python_reference/csv"

check_case() {
    local label=$1
    shift
    local reference="$OUT/$label.python"
    local native="$OUT/$label.mojo"
    local error="$OUT/$label.stderr"

    PYTHONHASHSEED=0 timeout --signal=KILL 180 \
        "$PYTHON" "$ROOT/python_reference/rpb" "$@" > "$reference"
    (
        cd "$TMP/runtime"
        timeout --signal=KILL 180 \
            "$ROOT/bin/mojo-runtime-exec" "$PROMPT" rpb "$@"
    ) > "$native" 2> "$error"

    if [[ -s "$error" ]]; then
        printf 'historical prompt emitted stderr: %s\n' "$label" >&2
        sed -n '1,80p' "$error" >&2
        exit 1
    fi
    if ! cmp "$reference" "$native"; then
        printf 'historical prompt parity failed: %s (%s)\n' "$label" "$*" >&2
        diff -u "$reference" "$native" | sed -n '1,180p' >&2 || true
        exit 1
    fi
    printf 'historical prompt family parity: %s\n' "$label"
}

# A leading one-character ``r`` activates the historical compact presentation
# path.  Before Stage 12c5ax each following family was planned natively but the
# conservative ownership predicate still sent the complete command to Python.
check_case moon       r mond          2 --art=csv --nocolor
check_case primecross r primzahlkreuz 2 --art=csv --nocolor
# ``alles`` is kept at plan level in the Mojo test: running the complete Python
# all-column generator belongs to the reusable full-reference workflow, not a
# routine stage gate.
check_case freedom    r freiheit      2 --art=csv --nocolor
check_case equality   r gleichheit    2 --art=csv --nocolor
check_case spheres    r kugeln        2 --art=csv --nocolor
check_case circles    r kreise        2 --art=csv --nocolor
check_case network    r netzwerk      2 --art=csv --nocolor
check_case complexity r komplex       2 --art=csv --nocolor

printf '%s\n' \
    'historical compact table families: 8/8 byte-identical without Python fallback'
