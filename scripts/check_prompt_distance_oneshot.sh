#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-distance-oneshot.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p target/bin "$TMP"
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi
ln -s "$ROOT/assets" "$TMP/assets"

run_prompt() {
    timeout --kill-after=10s 300s "$PROMPT" "$@" </dev/null
}

(
    cd "$TMP"
    run_prompt rpb abstand 1-2 5-6 10-11 > distance-multi.actual
    grep -Fx '1->: 10: 9, 11: 10' distance-multi.actual >/dev/null
    grep -Fx '6->: 1: 5, 2: 4' distance-multi.actual >/dev/null

    run_prompt rpb abstandPrim 1-2 5-6 10-11 > distance-prime.actual
    grep -F "1->: 10: ['3^2'], 11: [2, 5]" distance-prime.actual >/dev/null
    grep -F "6->: 1: [5], 2: ['2^2']" distance-prime.actual >/dev/null

    [[ ! -e python_reference ]]
    [[ ! -e target/bin/reta-native ]]
)
printf '%s\n' 'native distance one-shot smoke: 2/2 execute without Python or reta-native child process'
