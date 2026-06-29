#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-numeric-oneshot.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p target/bin "$TMP/python_reference"
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi
ln -s "$ROOT/assets" "$TMP/assets"
ln -s "$ROOT/python_reference/csv" "$TMP/python_reference/csv"

run_prompt() {
    timeout --kill-after=5s 60s "$PROMPT" "$@" </dev/null
}

(
    cd "$TMP"
    run_prompt rpb 15 > numeric-pure.actual
    grep -F '15: 3 5' numeric-pure.actual >/dev/null

    run_prompt rpb 1/2 > numeric-reciprocal.actual
    grep -F '1 / 2 Art und Weise' numeric-reciprocal.actual >/dev/null

    run_prompt rpb 3/2 > numeric-proper-fraction.actual
    grep -F '(3/2)' numeric-proper-fraction.actual >/dev/null

    run_prompt rpb 2,3 > numeric-list.actual
    grep -F '2:' numeric-list.actual >/dev/null

    run_prompt rpb 15_13 13 > numeric-basic.actual
    grep -F -- '--Grundstrukturen=Paradigmen_sind_Absichten_(13)' numeric-basic.actual >/dev/null

    run_prompt rpb 16_2 2 > numeric-multiverse.actual
    grep -F -- '--Multiversum=Strukturalien_bzw_Meta-Paradigmen' numeric-multiverse.actual >/dev/null

    run_prompt rpb 16_15_13 13 > numeric-basic-alias.actual
    grep -F -- '--Grundstrukturen=Paradigmen_sind_Absichten_(13)' numeric-basic-alias.actual >/dev/null

    run_prompt rpb 15_13 > numeric-empty.actual
    [[ ! -s numeric-empty.actual ]]

    run_prompt rpb u 0 --art=csv --nocolor > numeric-zero.actual
    grep -F -- '--vorhervonausschnitt=0' numeric-zero.actual >/dev/null
    grep -F -- '--Universum=transzendentalien' numeric-zero.actual >/dev/null

    run_prompt rpb u 2,-2 --art=csv --nocolor > numeric-collision.actual
    grep -F -- '--vorhervonausschnitt=-2,2' numeric-collision.actual >/dev/null

    run_prompt rpb u teiler 2,-2 --art=csv --nocolor \
        > numeric-divisor-collision.actual
    grep -F -- '--vorhervonausschnitt=,-2,2' \
        numeric-divisor-collision.actual >/dev/null

    run_prompt rpb u 1/2,-1/2 --art=csv --nocolor \
        > numeric-reciprocal-collision.actual
    grep -F -- '--vorhervonausschnitt=2,-2' \
        numeric-reciprocal-collision.actual >/dev/null

    run_prompt rpb u 2/4,-2/4 --art=csv --nocolor \
        > numeric-proper-collision.actual
    grep -F -- '--vorhervonausschnitt=4,-4' \
        numeric-proper-collision.actual >/dev/null

    run_prompt rpb u 2/3,-1/4 --art=csv --nocolor \
        > numeric-empty-positive.actual
    grep -F -- '--vorhervonausschnitt=,-4' \
        numeric-empty-positive.actual >/dev/null

    run_prompt rpb u 2/4,-1/2 --art=csv --nocolor \
        > numeric-reduced-collision.actual
    grep -F -- '--vorhervonausschnitt=2,-2' \
        numeric-reduced-collision.actual >/dev/null

    [[ ! -e target/bin/reta-native ]]
)
printf '%s\n' 'native numeric one-shot prompt smoke: 15/15 execute without Python or reta-native child process'
