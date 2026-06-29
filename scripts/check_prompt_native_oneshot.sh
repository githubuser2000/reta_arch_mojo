#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-native-oneshot.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p target/bin "$TMP/python_reference"
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi
ln -s "$ROOT/assets" "$TMP/assets"
ln -s "$ROOT/python_reference/csv" "$TMP/python_reference/csv"

(
    cd "$TMP"
    "$PROMPT" rpb prim 60 > prime.actual
    [[ $(cat prime.actual) == '60: 2^2 3 5' ]]
    "$PROMPT" retaPrompt -befehl multis 12 > multis.actual
    [[ $(cat multis.actual) == '12: [(6, 2), (4, 3)]' ]]
    "$PROMPT" rpb abc Test > abc.actual
    [[ $(cat abc.actual) == '20 5 19 20' ]]
    "$PROMPT" rpb leeren > clear.actual
    printf '\033[2J\033[H' > clear.expected
    cmp clear.expected clear.actual

    "$PROMPT" rpb universum 1/2 --nocolor --breite=0 > table.actual
    grep -F 'reta -zeilen --vorhervonausschnitt=2' table.actual >/dev/null
    grep -F '1 / 2 Art und Weise' table.actual >/dev/null
    [[ ! -e target/bin/reta-native ]]

    "$PROMPT" rpb reta -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon -ausgabe --art=csv --nocolor \
        > raw-reta.actual
    grep -F ';Religionen der Föderation' raw-reta.actual >/dev/null

    "$PROMPT" rpb a2 > compact-a.actual
    grep -F "'absicht 2' ergibt sich aus 'a2' und ergibt danach reta-Befehl:" compact-a.actual >/dev/null
    grep -F -- '--Menschliches=motivation' compact-a.actual >/dev/null

    "$PROMPT" rpb p12 > compact-p.actual
    grep -F "'12 mulpri multis prim primfaktorenvergleich' ergibt sich aus 'p12'" compact-p.actual >/dev/null
    grep -Fx '12: [(6, 2), (4, 3)]' compact-p.actual >/dev/null

    "$PROMPT" rpb G2 > compact-g.actual
    grep -F "'2 geist' ergibt sich aus 'G2' und ergibt danach reta-Befehl:" compact-g.actual >/dev/null
    grep -F -- '--Grundstrukturen=geist' compact-g.actual >/dev/null

    for compact_case in B2 E2 T2 W2 u2; do
        "$PROMPT" rpb "$compact_case" > "compact-$compact_case.actual"
        grep -F "ergibt danach reta-Befehl:reta " "compact-$compact_case.actual" >/dev/null
        [[ ! -e target/bin/reta-native ]]
    done

)
printf '%s\n' 'native one-shot prompt smoke: 14 representative command classes execute without Python or reta-native child process'
