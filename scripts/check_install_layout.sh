#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=${TMPDIR:-/tmp}/reta-install-layout.$$
STAGE=$TMP/stage
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"

DESTDIR=$STAGE PREFIX=/usr "$ROOT/scripts/install.sh" >"$TMP/install.log"

[ -f "$STAGE/usr/share/reta/csv/religion.csv" ]
[ -f "$STAGE/usr/share/reta/assets/parameter_aliases.tsv" ]
[ -f "$STAGE/usr/share/reta/assets/input_semantics_catalog.tsv" ]
[ -f "$STAGE/usr/share/reta/assets/reta_help_de.txt" ]
[ -f "$STAGE/usr/share/reta/assets/reta_help_en.txt" ]
[ -f "$STAGE/usr/share/reta/assets/i18n_words/deutsch.tsv" ]
[ -f "$STAGE/usr/share/reta/assets/i18n_words/manifest.json" ]
[ -f "$STAGE/usr/share/man/man1/generate_html.1" ]
[ -L "$STAGE/usr/bin/reta-mojo-i18n" ]
[ -L "$STAGE/usr/bin/reta-mojo-package-integrity" ]
[ -L "$STAGE/usr/lib/reta/python_reference/csv" ]
[ -L "$STAGE/usr/lib/reta/assets" ]
[ -x "$STAGE/usr/lib/reta/scripts/check_mojo_binary_freshness.sh" ]
[ -x "$STAGE/usr/lib/reta/scripts/current_source_id.sh" ]
[ -L "$STAGE/usr/bin/reta" ]
[ -L "$STAGE/usr/bin/grundStrukHtml" ]
[ -x "$STAGE/usr/lib/reta/target/bin/reta" ]
[ -x "$STAGE/usr/lib/reta/target/bin/grundStrukHtml" ]
[ -f "$STAGE/usr/lib/reta/target/lib/reta/libreta-core.so" ]
[ -f "$STAGE/usr/lib/reta/target/lib/reta/libreta-core.so.reta-source-id" ]

(
    cd "$TMP"
    "$STAGE/usr/bin/reta-mojo" --mojo-csv-info >"$TMP/csv-info.out"
)
grep -q '^Zeilen: 1025$' "$TMP/csv-info.out"
grep -q '^Spalten: 746$' "$TMP/csv-info.out"


(
    cd "$TMP"
    "$STAGE/usr/bin/reta-mojo-i18n" --summary english >"$TMP/i18n-summary.out"
)
grep -q '^language=english$' "$TMP/i18n-summary.out"
grep -q '^rows=13655$' "$TMP/i18n-summary.out"
grep -q '^legacy_monolith_rows=6720$' "$TMP/i18n-summary.out"
grep -q '^matrix_rows=4766$' "$TMP/i18n-summary.out"

(
    cd "$TMP"
    "$STAGE/usr/bin/reta-mojo-package-integrity" --summary \
        "$ROOT/python_reference" >"$TMP/package-integrity.out"
)
grep -q '^file_count=457$' "$TMP/package-integrity.out"
grep -q '^missing_required=0$' "$TMP/package-integrity.out"
grep -q '^suspicious_csvs=0$' "$TMP/package-integrity.out"

# The public HTML generator must be usable from an arbitrary, non-install
# working directory and must not create the historical middle.alx implicitly.
printf 'installed-middle\n' > "$TMP/middle.fixture"
cat "$ROOT/assets/html/head1.alx" \
    "$ROOT/assets/html/religionen.js" \
    "$ROOT/assets/html/head2.alx" \
    "$TMP/middle.fixture" \
    "$ROOT/tests/fixtures/grundstrukturen_html/blank-de.html" \
    "$ROOT/assets/html/footer.alx" > "$TMP/generate-html.expected"
mkdir -p "$TMP/caller"
(
    cd "$TMP/caller"
    "$STAGE/usr/bin/generate_html" \
        --middle-file "$TMP/middle.fixture" \
        --middle-output "$TMP/middle.saved" \
        --output "$TMP/generate-html.actual"
    "$STAGE/usr/bin/generate_html" --help > "$TMP/generate-html.help"
    "$STAGE/usr/bin/generate_html" --version > "$TMP/generate-html.version"
)
cmp "$TMP/generate-html.expected" "$TMP/generate-html.actual"
cmp "$TMP/middle.fixture" "$TMP/middle.saved"
[ ! -e "$TMP/caller/middle.alx" ]
grep -q -- '--middle-file' "$TMP/generate-html.help"
grep -q 'reta Mojo HTML generator' "$TMP/generate-html.version"

set -- \
    -zeilen --vorhervonausschnitt=1-2 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=csv --breite=40
(
    cd "$ROOT"
    python3 python_reference/reta.py "$@" >"$TMP/reference.out"
)
(
    cd "$TMP"
    "$STAGE/usr/bin/reta-native" "$@" >"$TMP/native.out"
    "$STAGE/usr/bin/reta" "$@" >"$TMP/core-launcher.out"
)
cmp "$TMP/reference.out" "$TMP/native.out"
cmp "$TMP/reference.out" "$TMP/core-launcher.out"

(
    cd "$TMP"
    RETA_PYTHON=/definitely/not/available "$STAGE/usr/bin/reta" -h         >"$TMP/installed-help-de.out"
    RETA_PYTHON=/definitely/not/available "$STAGE/usr/bin/reta"         -language=english -h >"$TMP/installed-help-en.out"
)
cmp "$ROOT/assets/reta_help_de.txt" "$TMP/installed-help-de.out"
cmp "$ROOT/assets/reta_help_en.txt" "$TMP/installed-help-en.out"

DESTDIR=$STAGE PREFIX=/usr "$ROOT/scripts/uninstall.sh" >/dev/null
[ ! -e "$STAGE/usr/lib/reta" ]
[ ! -e "$STAGE/usr/share/reta" ]

printf '%s\n' 'FHS-Installation: Layout, native CSV, Core-Starter und Deinstallation bestanden.'
