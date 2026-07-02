#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
[ "$#" -eq 1 ] || {
    printf 'Aufruf: %s <python-all.html|reference.tar.bz2>\n' "$0" >&2
    exit 2
}
REFERENCE=$1
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
[ -x "$NATIVE" ] || {
    printf 'Native binary fehlt: %s\n' "$NATIVE" >&2
    exit 2
}
TMP=${RETA_FULL_ALL_TMPDIR:-"${TMPDIR:-/tmp}/reta-full-all-reference.$$"}
KEEP=${RETA_KEEP_FULL_ALL_OUTPUT:-0}
mkdir -p "$TMP"
if [ "$KEEP" != 1 ]; then
    trap 'rm -rf "$TMP"' EXIT HUP INT TERM
fi
case "$REFERENCE" in
    *.tar.bz2|*.tbz2)
        tar -xjf "$REFERENCE" -C "$TMP"
        PYTHON_HTML="$TMP/python-all.html"
        ;;
    *)
        PYTHON_HTML=$REFERENCE
        ;;
esac
[ -f "$PYTHON_HTML" ] || {
    printf 'Python-Referenzausgabe fehlt: %s\n' "$PYTHON_HTML" >&2
    exit 2
}
NATIVE_HTML="$TMP/native-all.html"
NATIVE_TIME="$TMP/native.time"
ARGS='-spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor'
# shellcheck disable=SC2086
/usr/bin/time -f 'native_seconds=%e\nnative_max_rss_kib=%M' -o "$NATIVE_TIME" \
    "$NATIVE" $ARGS > "$NATIVE_HTML"
cat "$NATIVE_TIME"
python3 scripts/compare_full_all_html.py "$PYTHON_HTML" "$NATIVE_HTML"
if [ "$KEEP" = 1 ]; then
    printf 'Ausgaben behalten unter %s\n' "$TMP"
fi
