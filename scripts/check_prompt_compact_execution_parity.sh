#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
PYTHON=${PYTHON_BIN:-python3}
FIXTURES=tests/fixtures/prompt_compact_execution
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-compact-parity.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p target/bin "$FIXTURES"
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi

regenerate_case() {
    local label=$1
    shift
    PYTHONHASHSEED=0 "$PYTHON" python_reference/rpb "$@" \
        > "$FIXTURES/$label.expected"
}

check_case() {
    local label=$1
    shift
    if [[ ${RETA_REGENERATE_PROMPT_COMPACT_FIXTURES:-0} == 1 ]]; then
        regenerate_case "$label" "$@"
    fi
    "$PROMPT" rpb "$@" > "$TMP/$label.mojo"
    if ! cmp "$FIXTURES/$label.expected" "$TMP/$label.mojo"; then
        echo "compact prompt parity failed: $label ($*)" >&2
        diff -u "$FIXTURES/$label.expected" "$TMP/$label.mojo" \
            | sed -n '1,160p' >&2 || true
        exit 1
    fi
    printf 'compact prompt parity: %s\n' "$label"
}

check_case a1 a1
check_case a2 a2
check_case ap15 ap15
check_case p12 p12
check_case p13 p13
check_case G2 G2
check_case B2 B2
check_case E2 E2
check_case T2 T2
check_case W2 W2
check_case u2 u2

printf '%s\n' 'compact prompt execution fixtures: 11/11 byte-identical'
