#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/prompt_session_batch_probe.mojo -o target/tests/prompt_session_batch_probe
if [ -n "${RETA_PYTHON:-}" ]; then
    PYTHON=$RETA_PYTHON
elif [ -x "$ROOT/.venv/bin/python" ]; then
    PYTHON="$ROOT/.venv/bin/python"
else
    PYTHON=python3
fi
TMP=${TMPDIR:-/tmp}/reta-prompt-session.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
cat > "$TMP/deutsch.tsv" <<'EOF2'
state	empty	
state	compact	p5
state	spaces	p5   (1 2)
state	reta	reta   -zeilen  --zeit=heute
state	utf8	größe  mond
delete	position	reta -h --nocolor	2
delete	decimal-token	reta 2 --nocolor	2
delete	range	a b c d e	2-4
delete	token	a e x y x	x
apply	normal	0	reta -h	current	--nocolor
apply	stored	3	reta -h	current	--nocolor
apply	addition	5	reta -h	current	--nocolor
history	empty	
history	log-on	loggen
history	log-off	nichtloggen
history	command	prim 60
combine	reta-both	reta -h	reta --nocolor
combine	simple	prim	60
EOF2
cat > "$TMP/english.tsv" <<'EOF2'
state	empty	
state	compact	i5
state	spaces	i5   (1 2)
state	reta	reta   -lines  --time=today
state	utf8	size  moon
delete	position	reta -h --nocolor	2
delete	decimal-token	reta 2 --nocolor	2
delete	range	a b c d e	2-4
delete	token	a e x y x	x
apply	normal	0	reta -h	current	--nocolor
apply	stored	3	reta -h	current	--nocolor
apply	addition	5	reta -h	current	--nocolor
history	empty	
history	log-on	logging_yes
history	log-off	logging_no
history	command	prime 60
combine	reta-both	reta -h	reta --nocolor
combine	simple	prime	60
EOF2
for language in deutsch english; do
    PYTHONHASHSEED=0 "$PYTHON" scripts/prompt_session_reference_batch.py "$language" "$TMP/$language.tsv" > "$TMP/$language.python"
    target/tests/prompt_session_batch_probe "$language" "$TMP/$language.tsv" > "$TMP/$language.mojo"
    if ! cmp "$TMP/$language.python" "$TMP/$language.mojo"; then
        diff -u "$TMP/$language.python" "$TMP/$language.mojo" || true
        exit 1
    fi
    printf '%-10s %3s prompt-session contexts byte-identical\n' "$language" "$(grep -c '^@@@' "$TMP/$language.mojo")"
done
printf '%s\n' 'Prompt-Sitzungszustand ist in 36 Kontexten bytegleich.'
