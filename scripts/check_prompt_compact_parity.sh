#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
"$MOJO" build -I src tests/prompt_compact_batch_probe.mojo -o target/tests/prompt_compact_batch_probe
TMP=${TMPDIR:-/tmp}/reta-prompt-compact.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
cat > "$TMP/deutsch.tsv" <<'EOF2'
a15	0	0	a15
ap15	0	0	ap15
pure15	0	0	15
brackets	0	0	(1 2)
ee	0	0	ee
reta	0	0	reta -h
two-tokens	0	0	a 15
rotated	0	0	15a
p12	0	0	p12
fraction	0	0	3/2
fraction-force-e	0	1	3/2
selective	1	0	15
uv-fraction	0	0	uv3/2
multi	0	0	a15 e
numeric-shortcut	0	0	15_10
EOF2
cat > "$TMP/english.tsv" <<'EOF2'
i15	0	0	i15
ip15	0	0	ip15
pure15	0	0	15
brackets	0	0	(1 2)
ee	0	0	ee
reta	0	0	reta -h
p12	0	0	p12
fraction	0	0	3/2
fraction-force-e	0	1	3/2
selective	1	0	15
uC-fraction	0	0	uC3/2
numeric-shortcut	0	0	16_5
EOF2
for language in deutsch english; do
    PYTHONHASHSEED=0 "$PYTHON" scripts/prompt_compact_reference_batch.py "$language" "$TMP/$language.tsv" > "$TMP/$language.python"
    target/tests/prompt_compact_batch_probe "$language" "$TMP/$language.tsv" > "$TMP/$language.mojo"
    if ! cmp "$TMP/$language.python" "$TMP/$language.mojo"; then
        diff -u "$TMP/$language.python" "$TMP/$language.mojo" || true
        exit 1
    fi
    printf '%-10s %3s compact contexts byte-identical\n' "$language" "$(grep -c '^@@@' "$TMP/$language.mojo")"
done
printf '%s\n' 'Kompakte Prompt-Sprache ist in 27 Kontexten bytegleich.'
