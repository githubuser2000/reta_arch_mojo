#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-html-parity.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"; rm -f "$ROOT/middle.alx"' EXIT HUP INT TERM

for name in head1.alx religionen.js head2.alx footer.alx; do
    cmp "python_reference/$name" "assets/html/$name"
done

if [ ! -x target/bin/grundStrukHtml-native ]; then
    mkdir -p target/bin
    "$ROOT/bin/mojo-real" build -I src src/grundstruk_html_main.mojo -o target/bin/grundStrukHtml-native
fi
if [ ! -x target/bin/generate-html-native ]; then
    mkdir -p target/bin
    "$ROOT/bin/mojo-real" build -I src src/generate_html_main.mojo -o target/bin/generate-html-native
fi

FIXTURES="$ROOT/tests/fixtures/grundstrukturen_html"
if [ "${RETA_REFRESH_HTML_FIXTURES:-0}" = 1 ]; then
    python3 tools/capture_grundstrukturen_reference.py "$TMP"
    python3 tools/capture_grundstrukturen_reference.py "$TMP" --language=english
    cp "$TMP/python-normal-de" "$FIXTURES/normal-de.html"
    cp "$TMP/python-blank-de" "$FIXTURES/blank-de.html"
    cp "$TMP/python-debug-de" "$FIXTURES/debug-de.html"
    cp "$TMP/python-normal-en" "$FIXTURES/normal-en.html"
    cp "$TMP/python-blank-en" "$FIXTURES/blank-en.html"
    cp "$TMP/python-debug-en" "$FIXTURES/debug-en.html"
fi
cp "$FIXTURES/normal-de.html" "$TMP/python-normal-de"
cp "$FIXTURES/blank-de.html" "$TMP/python-blank-de"
cp "$FIXTURES/debug-de.html" "$TMP/python-debug-de"
cp "$FIXTURES/normal-en.html" "$TMP/python-normal-en"
cp "$FIXTURES/blank-en.html" "$TMP/python-blank-en"
cp "$FIXTURES/debug-en.html" "$TMP/python-debug-en"

./target/bin/grundStrukHtml-native > "$TMP/mojo-normal-de"
./target/bin/grundStrukHtml-native blank > "$TMP/mojo-blank-de"
./target/bin/grundStrukHtml-native -language=english > "$TMP/mojo-normal-en"
./target/bin/grundStrukHtml-native blank -language=english > "$TMP/mojo-blank-en"
./target/bin/grundStrukHtml-native -debug > "$TMP/mojo-debug-de"
./target/bin/grundStrukHtml-native -debug -language=english > "$TMP/mojo-debug-en"

cmp "$TMP/python-normal-de" "$TMP/mojo-normal-de"
cmp "$TMP/python-blank-de" "$TMP/mojo-blank-de"
cmp "$TMP/python-normal-en" "$TMP/mojo-normal-en"
cmp "$TMP/python-blank-en" "$TMP/mojo-blank-en"
cmp "$TMP/python-debug-de" "$TMP/mojo-debug-de"
cmp "$TMP/python-debug-en" "$TMP/mojo-debug-en"

./grundStrukHtml.py blank > "$TMP/root-blank-de"
./run/grundStrukHtml.py blank > "$TMP/run-blank-de"
cmp "$TMP/python-blank-de" "$TMP/root-blank-de"
cmp "$TMP/python-blank-de" "$TMP/run-blank-de"

printf 'test-middle\n' > "$TMP/middle"
cat assets/html/head1.alx assets/html/religionen.js assets/html/head2.alx \
    "$TMP/middle" "$TMP/python-blank-de" assets/html/footer.alx > "$TMP/full-reference"
RETA_GENERATE_HTML_MIDDLE_FILE="$TMP/middle" ./target/bin/generate-html-native > "$TMP/full-mojo"
RETA_GENERATE_HTML_MIDDLE_FILE="$TMP/middle" ./generate_html > "$TMP/full-root"
RETA_GENERATE_HTML_MIDDLE_FILE="$TMP/middle" ./run/generate_html > "$TMP/full-run"
cmp "$TMP/full-reference" "$TMP/full-mojo"
cmp "$TMP/full-reference" "$TMP/full-root"
cmp "$TMP/full-reference" "$TMP/full-run"

cat assets/html/head1.alx assets/html/religionen.js assets/html/head2.alx \
    "$TMP/middle" "$TMP/python-blank-en" assets/html/footer.alx > "$TMP/full-reference-en"
RETA_GENERATE_HTML_MIDDLE_FILE="$TMP/middle" ./generate_html -language=english > "$TMP/full-mojo-en"
cmp "$TMP/full-reference-en" "$TMP/full-mojo-en"

# Exercise the real table pipeline with all columns but one row.  The
# default historical generator remains unbounded; this test seam keeps CI
# finite while crossing the actual compatibility boundary.
RETA_GENERATE_HTML_ROWS=1 ./target/bin/generate-html-native > "$TMP/full-real-small"
cmp tests/fixtures/generate_html/middle-all-row1-de.html middle.alx
cat assets/html/head1.alx assets/html/religionen.js assets/html/head2.alx \
    middle.alx "$TMP/python-blank-de" assets/html/footer.alx > "$TMP/full-real-small-reference"
cmp "$TMP/full-real-small-reference" "$TMP/full-real-small"
test -s middle.alx

RETA_GENERATE_HTML_ROWS=1 ./target/bin/generate-html-native -language=english \
    > "$TMP/full-real-small-en"
cmp tests/fixtures/generate_html/middle-all-row1-en.html middle.alx
cat assets/html/head1.alx assets/html/religionen.js assets/html/head2.alx \
    middle.alx "$TMP/python-blank-en" assets/html/footer.alx \
    > "$TMP/full-real-small-reference-en"
cmp "$TMP/full-real-small-reference-en" "$TMP/full-real-small-en"
test -s middle.alx

printf '%s\n' 'GrundstrukHtml und generate_html sind bytegleich zur Referenz.'
