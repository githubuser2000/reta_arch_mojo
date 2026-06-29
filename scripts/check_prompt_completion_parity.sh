#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/prompt_completion_batch_probe.mojo -o target/tests/prompt_completion_batch_probe
TMP=${TMPDIR:-/tmp}/reta-prompt-completion.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
cat > "$TMP/english.tsv" <<'EOF'
root-pri	pri
reta-main	reta 
output-parameters	reta -output 
output-type-fuzzy	reta -output --type=h
line-values-comma	reta -lines --type=sun,mo
combination-values	reta -combination --galaxy=ani
EOF
cat > "$TMP/deutsch.tsv" <<'EOF'
root-prim	prim
reta-haupt	reta 
ausgabe-parameter	reta -ausgabe 
ausgabe-art-fuzzy	reta -ausgabe --art=h
zeilen-werte-komma	reta -zeilen --typ=sonne,mo
kombi-werte	reta -kombination --galaxie=tier
EOF
for language in english deutsch; do
    PYTHONHASHSEED=0 python3 scripts/prompt_completion_reference_batch.py "$language" "$TMP/$language.tsv" > "$TMP/$language.python"
    target/tests/prompt_completion_batch_probe "$language" "$TMP/$language.tsv" > "$TMP/$language.mojo"
    cmp "$TMP/$language.python" "$TMP/$language.mojo"
    printf '%-10s %5s candidates in 6 contexts\n' "$language" "$(grep -v '^@@@' "$TMP/$language.mojo" | wc -l)"
done
printf '%s\n' 'Verschachtelte Prompt-Completion ist in 12 Kontexten bytegleich.'
