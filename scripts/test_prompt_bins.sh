#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-prompt-bins.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

# Build once so integration tests exercise the same executable users receive.
mkdir -p target/bin
if [ ! -x target/bin/reta-prompt-native ]; then
    "$ROOT/bin/mojo-real" build -I src src/prompt_main.mojo -o target/bin/reta-prompt-native
fi
if [ ! -x target/bin/reta-mojo-compat-bin ]; then
    "$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src src/compat_main.mojo -o target/bin/reta-mojo-compat-bin
fi
if [ ! -x target/bin/reta-prompt-complete ]; then
    "$ROOT/bin/mojo-real" build -I src src/prompt_completion_main.mojo -o target/bin/reta-prompt-complete
fi

[ "$(./bin/rpb prim 60)" = "60: 2^2 3 5" ]
[ "$(./bin/prim24 29)" = "29: 5" ]
[ "$(./bin/multis 12)" = "12: [(6, 2), (4, 3), (12, 1)]" ]
[ "$(./bin/multis3 36)" = "36: [(2, 2, 9), (2, 3, 6), (3, 3, 4)]" ]
./bin/modulo 5 > "$TMP/modulo"
[ "$(wc -l < "$TMP/modulo")" -eq 24 ]
[ "$(head -n 1 "$TMP/modulo")" = "5 % 2 = 1 Gegenteil, 1 Gegenteil" ]

printf 'prim 29\nq\n' | ./bin/rp > "$TMP/interactive"
grep -F '29: 29' "$TMP/interactive" >/dev/null

./bin/reta -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon --breite=40 > "$TMP/reta"
./bin/rpb reta -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon --breite=40 > "$TMP/rpb-reta"
cmp "$TMP/reta" "$TMP/rpb-reta"

python3 python_reference/retaPrompt.py -vi -e -befehl a 2 > "$TMP/python-a"
./bin/rpb a 2 > "$TMP/mojo-a"
cmp "$TMP/python-a" "$TMP/mojo-a"

printf 'S\nprim 60\no\nq\n' | ./bin/rp > "$TMP/storage"
grep -F 'Gespeichert: prim 60' "$TMP/storage" >/dev/null
grep -F '60: 2^2 3 5' "$TMP/storage" >/dev/null

printf '%s\n' 'Prompt-Binärtests bestanden.'
