#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-native-io.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP/python_reference"
ln -s "$ROOT/assets" "$TMP/assets"
ln -s "$ROOT/python_reference/csv" "$TMP/python_reference/csv"

for source in     src/reta_mojo/csv_table.mojo     src/prompt_completion_main.mojo     src/generate_html_main.mojo     src/compat_main.mojo; do
    if grep -q '^from std.python import' "$source"; then
        printf 'Unerwarteter std.python-Import: %s\n' "$source" >&2
        exit 1
    fi
done

for binary in reta-native reta-prompt-complete generate-html-native reta-mojo-compat-bin; do
    test -x "$ROOT/target/bin/$binary" || {
        printf 'Fehlendes natives I/O-Binary: %s\n' "$binary" >&2
        exit 1
    }
    if command -v readelf >/dev/null 2>&1 && \
       readelf -d "$ROOT/target/bin/$binary" 2>/dev/null | grep NEEDED | grep -qi libpython; then
        printf 'Unerwartete libpython-Abhängigkeit: %s\n' "$binary" >&2
        exit 1
    fi
done

(
    cd "$TMP"
    "$ROOT/target/bin/reta-native" \
        -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon \
        -ausgabe --art=shell --breite=40 > table.actual
)
cmp "$ROOT/tests/fixtures/shell/shell-de-width40.out" "$TMP/table.actual"

a='keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar'
cat > "$TMP/completion.expected" <<EOF_EXPECTED
6
abc
abcd
absicht
absichten
EIGNfamiliebrauchen
$a
EOF_EXPECTED
printf 'abc\n' | "$ROOT/target/bin/reta-prompt-complete" deutsch "$ROOT/assets" \
    > "$TMP/completion.actual"
cmp "$TMP/completion.expected" "$TMP/completion.actual"
printf 'abc' | "$ROOT/target/bin/reta-prompt-complete" deutsch "$ROOT/assets" \
    > "$TMP/completion-eof.actual"
cmp "$TMP/completion.expected" "$TMP/completion-eof.actual"
printf 'abc\r\n' | "$ROOT/target/bin/reta-prompt-complete" deutsch "$ROOT/assets" \
    > "$TMP/completion-crlf.actual"
cmp "$TMP/completion.expected" "$TMP/completion-crlf.actual"

printf 'native-middle\n' > "$TMP/middle"
cat "$ROOT/assets/html/head1.alx" \
    "$ROOT/assets/html/religionen.js" \
    "$ROOT/assets/html/head2.alx" \
    "$TMP/middle" \
    "$ROOT/tests/fixtures/grundstrukturen_html/blank-de.html" \
    "$ROOT/assets/html/footer.alx" > "$TMP/html.expected"
(
    cd "$TMP"
    RETA_REFERENCE_PYTHON=/definitely/not/available \
    RETA_GENERATE_HTML_MIDDLE_FILE="$TMP/middle" \
        "$ROOT/target/bin/generate-html-native" > html.actual
)
cmp "$TMP/html.expected" "$TMP/html.actual"

(
    cd "$TMP"
    RETA_REFERENCE_PYTHON=/definitely/not/available \
    RETA_GENERATE_HTML_ROWS=1 \
        "$ROOT/target/bin/generate-html-native" > html-native-all.actual
)
test -s "$TMP/html-native-all.actual"
test -s "$TMP/middle.alx"
if grep -q '^from std\.subprocess import' "$ROOT/src/generate_html_main.mojo"; then
    printf '%s\n' 'generate_html enthält unerwartet noch eine Subprozessbrücke.' >&2
    exit 1
fi

printf '%s\n' 'Native Datei-, Pipe- und generate_html-I/O funktionieren ohne CPython-Runtime oder Python-Kindprozess.'
