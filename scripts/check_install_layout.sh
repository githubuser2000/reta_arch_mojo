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
[ -f "$STAGE/usr/share/reta/assets/reta_help_de.txt" ]
[ -f "$STAGE/usr/share/reta/assets/reta_help_en.txt" ]
[ -f "$STAGE/usr/share/reta/assets/i18n_words/deutsch.tsv" ]
[ -f "$STAGE/usr/share/reta/assets/i18n_words/manifest.json" ]
[ -L "$STAGE/usr/bin/reta-mojo-i18n" ]
[ -L "$STAGE/usr/lib/reta/python_reference/csv" ]
[ -L "$STAGE/usr/lib/reta/assets" ]
[ -L "$STAGE/usr/bin/reta" ]

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
grep -q '^rows=6935$' "$TMP/i18n-summary.out"
grep -q '^matrix_rows=4766$' "$TMP/i18n-summary.out"

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
    RETA_FORCE_REFERENCE=1 "$STAGE/usr/bin/reta" "$@" \
        >"$TMP/compat-reference.out"
)
cmp "$TMP/reference.out" "$TMP/native.out"
cmp "$TMP/reference.out" "$TMP/compat-reference.out"

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

printf '%s\n' 'FHS-Installation: Layout, native CSV, Python-Fallback und Deinstallation bestanden.'
