#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
"$MOJO" build -I src tests/prompt_preparation_full_batch_probe.mojo \
    -o target/tests/prompt_preparation_full_batch_probe
TMP=${TMPDIR:-/tmp}/reta-prompt-preparation-full.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
cat > "$TMP/deutsch.tsv" <<'EOF'
plain		0	0	0	prim 60		0
number	reta	0	0	0	15		0
range	reta	0	0	0	range 15-17		0
multiple-short	reta	0	0	0	v 3-4		0
multiple-long	reta	0	0	0	vielfache 5		0
divisor-short	reta	0	0	0	w 12		0
divisor-long	reta	0	0	0	teiler 18		0
existing	reta	0	0	0	reta -zeilen --zeit=heute 3 -ausgabe --art=html		0
selective		0	6	0	60	prim	0
compact		0	0	0	a15		0
regex-output		0	0	0	reta -ausgabe r"art"=r"ht.*"		0
regex-row		0	0	0	reta -zeilen r"zeit"=r"he.*"		0
EOF
cat > "$TMP/international.tsv" <<'EOF'
plain		0	0	0	prime 60		0
number	reta	0	0	0	15		0
range	reta	0	0	0	range 15-17		0
multiple-short	reta	0	0	0	m 3-4		0
multiple-long	reta	0	0	0	multiple 5		0
divisor-short	reta	0	0	0	d 12		0
divisor-long	reta	0	0	0	divider 18		0
existing	reta	0	0	0	reta -lines --time=today 3 -output --type=html		0
selective		0	6	0	60	prime	0
compact		0	0	0	i15		0
regex-output		0	0	0	reta -output r"type"=r"ht.*"		0
regex-row		0	0	0	reta -lines r"time"=r"to.*"		0
EOF
for language in deutsch english vietnamese chinese korean; do
    cases="$TMP/international.tsv"
    if [ "$language" = deutsch ]; then cases="$TMP/deutsch.tsv"; fi
    PYTHONHASHSEED=0 "$PYTHON" scripts/prompt_preparation_full_reference.py \
        "$language" "$cases" > "$TMP/$language.python"
    target/tests/prompt_preparation_full_batch_probe "$language" "$cases" \
        > "$TMP/$language.mojo"
    if ! cmp "$TMP/$language.python" "$TMP/$language.mojo"; then
        diff -u "$TMP/$language.python" "$TMP/$language.mojo" || true
        exit 1
    fi
    printf '%-12s %3s full preparation contexts byte-identical\n' \
        "$language" "$(grep -c '^@@@' "$TMP/$language.mojo")"
done
printf '%s\n' 'Volle Promptvorbereitung ist in 60 Kontexten bytegleich.'
