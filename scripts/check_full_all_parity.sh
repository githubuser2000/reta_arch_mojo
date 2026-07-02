#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ -n "${RETA_FULL_ALL_REFERENCE-}" ]; then
    exec "$ROOT/scripts/check_full_all_against_reference.sh" "$RETA_FULL_ALL_REFERENCE"
fi
BUNDLED_REFERENCE="$ROOT/tests/references/reta-python-full-all-reference-v1.tar.bz2"
if [ "${RETA_REGENERATE_FULL_ALL_REFERENCE:-0}" != 1 ] && [ -f "$BUNDLED_REFERENCE" ]; then
    exec "$ROOT/scripts/check_full_all_against_reference.sh" "$BUNDLED_REFERENCE"
fi
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
[ -x "$NATIVE" ] || {
    printf 'Native binary fehlt: %s\n' "$NATIVE" >&2
    exit 2
}
TMP=${RETA_FULL_ALL_TMPDIR:-"${TMPDIR:-/tmp}/reta-full-all.$$"}
KEEP=${RETA_KEEP_FULL_ALL_OUTPUT:-0}
mkdir -p "$TMP"
if [ "$KEEP" != 1 ]; then
    trap 'rm -rf "$TMP"' EXIT HUP INT TERM
fi
NATIVE_HTML="$TMP/native.html"
PYTHON_HTML="$TMP/python.html"
NATIVE_TIME="$TMP/native.time"
PYTHON_TIME="$TMP/python.time"
ARGS='-spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor'
# shellcheck disable=SC2086
/usr/bin/time -f 'native_seconds=%e\nnative_max_rss_kib=%M' -o "$NATIVE_TIME" \
    "$NATIVE" $ARGS > "$NATIVE_HTML"
# shellcheck disable=SC2086
PYTHONHASHSEED=0 /usr/bin/time -f 'python_seconds=%e\npython_max_rss_kib=%M' -o "$PYTHON_TIME" \
    "$PYTHON" python_reference/reta.py $ARGS > "$PYTHON_HTML"
cat "$NATIVE_TIME"
cat "$PYTHON_TIME"
python3 scripts/compare_full_all_html.py "$PYTHON_HTML" "$NATIVE_HTML"
if [ "$KEEP" = 1 ]; then
    printf 'Ausgaben behalten unter %s\n' "$TMP"
fi
