#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
"$MOJO" build -I src tests/prompt_preparation_batch_probe.mojo -o target/tests/prompt_preparation_batch_probe
TMP=${TMPDIR:-/tmp}/reta-prompt-preparation.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
cat > "$TMP/deutsch.tsv" <<'EOF2'
a15	0	0	a15
ap15	0	0	ap15
pure15	0	0	15
brackets	0	0	(1 2)
mixed	0	0	a15 e
p12	0	0	p12
fraction	0	0	uv3/2
normal	0	0	prim 60
reta	0	0	reta -h
shell	0	0	shell echo hi
force-e	0	1	3/2
selective	1	0	15
EOF2
cat > "$TMP/english.tsv" <<'EOF2'
i15	0	0	i15
ip15	0	0	ip15
pure15	0	0	15
brackets	0	0	(1 2)
p12	0	0	p12
fraction	0	0	uC3/2
normal	0	0	prime 60
reta	0	0	reta -h
shell	0	0	shell echo hi
force-e	0	1	3/2
selective	1	0	15
EOF2
for language in deutsch english; do
    PYTHONHASHSEED=0 "$PYTHON" scripts/prompt_preparation_reference_batch.py "$language" "$TMP/$language.tsv" > "$TMP/$language.python"
    target/tests/prompt_preparation_batch_probe "$language" "$TMP/$language.tsv" > "$TMP/$language.mojo"
    if ! cmp "$TMP/$language.python" "$TMP/$language.mojo"; then
        diff -u "$TMP/$language.python" "$TMP/$language.mojo" || true
        exit 1
    fi
    printf '%-10s %3s preparation contexts byte-identical\n' "$language" "$(grep -c '^@@@' "$TMP/$language.mojo")"
done
printf '%s\n' 'Vordere Promptvorbereitung ist in 23 Kontexten bytegleich.'
