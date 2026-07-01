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
[ -L "$STAGE/usr/lib/reta/python_reference/csv" ]
[ -L "$STAGE/usr/lib/reta/assets" ]
[ -L "$STAGE/usr/bin/reta" ]

(
    cd "$TMP"
    "$STAGE/usr/bin/reta-mojo" --mojo-csv-info >"$TMP/csv-info.out"
)
grep -q '^Zeilen: 1025$' "$TMP/csv-info.out"
grep -q '^Spalten: 746$' "$TMP/csv-info.out"

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

DESTDIR=$STAGE PREFIX=/usr "$ROOT/scripts/uninstall.sh" >/dev/null
[ ! -e "$STAGE/usr/lib/reta" ]
[ ! -e "$STAGE/usr/share/reta" ]

printf '%s\n' 'FHS-Installation: Layout, native CSV, Python-Fallback und Deinstallation bestanden.'
