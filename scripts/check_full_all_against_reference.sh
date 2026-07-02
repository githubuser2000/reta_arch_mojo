#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

DEFAULT_REFERENCE="$ROOT/tests/references/reta-python-full-all-reference-v1.tar.bz2"
case "$#" in
    0) REFERENCE=$DEFAULT_REFERENCE ;;
    1) REFERENCE=$1 ;;
    *)
        printf 'Aufruf: %s [python-all.html|reference.tar.bz2]\n' "$0" >&2
        exit 2
        ;;
esac

NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
[ -x "$NATIVE" ] || {
    printf 'Native binary fehlt: %s\n' "$NATIVE" >&2
    exit 2
}
[ -f "$REFERENCE" ] || {
    printf 'Referenz fehlt: %s\n' "$REFERENCE" >&2
    exit 2
}

TMP=${RETA_FULL_ALL_TMPDIR:-"${TMPDIR:-/tmp}/reta-full-all-reference.$$"}
KEEP=${RETA_KEEP_FULL_ALL_OUTPUT:-0}
mkdir -p "$TMP"
if [ "$KEEP" != 1 ]; then
    trap 'rm -rf "$TMP"' EXIT HUP INT TERM
fi

METADATA=
case "$REFERENCE" in
    *.tar.bz2|*.tbz2)
        tar -xjf "$REFERENCE" -C "$TMP"
        PYTHON_HTML="$TMP/python-all.html"
        [ -f "$TMP/metadata.txt" ] && METADATA=$TMP/metadata.txt
        ;;
    *)
        PYTHON_HTML=$REFERENCE
        ;;
esac
[ -f "$PYTHON_HTML" ] || {
    printf 'Python-Referenzausgabe fehlt: %s\n' "$PYTHON_HTML" >&2
    exit 2
}

COMPARE_ARGS=
if [ -n "$METADATA" ]; then
    expected_sha=$(sed -n 's/^sha256=//p' "$METADATA" | head -n1)
    expected_bytes=$(sed -n 's/^bytes=//p' "$METADATA" | head -n1)
    actual_sha=$(sha256sum "$PYTHON_HTML" | awk '{print $1}')
    actual_bytes=$(wc -c < "$PYTHON_HTML" | tr -d ' ')
    [ -z "$expected_sha" ] || [ "$expected_sha" = "$actual_sha" ] || {
        printf 'Referenz-SHA stimmt nicht: erwartet %s, erhalten %s\n' \
            "$expected_sha" "$actual_sha" >&2
        exit 1
    }
    [ -z "$expected_bytes" ] || [ "$expected_bytes" = "$actual_bytes" ] || {
        printf 'Referenzgröße stimmt nicht: erwartet %s, erhalten %s\n' \
            "$expected_bytes" "$actual_bytes" >&2
        exit 1
    }
    if grep -q '^pythonhashseed=uncontrolled$' "$METADATA"; then
        COMPARE_ARGS=--allow-unseeded-python
    fi
    printf '%s\n' 'Referenzmetadaten:'
    sed -n '/^command=/p;/^pythonhashseed=/p;/^python_version=/p;/^sha256=/p;/^bytes=/p;/^table_rows=/p;/^table_cells=/p' "$METADATA"
fi

NATIVE_HTML=${RETA_NATIVE_HTML:-"$TMP/native-all.html"}
if [ -z "${RETA_NATIVE_HTML-}" ]; then
    NATIVE_TIME="$TMP/native.time"
    ARGS='-spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor'
    # shellcheck disable=SC2086
    /usr/bin/time -f 'native_seconds=%e\nnative_max_rss_kib=%M' -o "$NATIVE_TIME" \
        "$NATIVE" $ARGS > "$NATIVE_HTML"
    cat "$NATIVE_TIME"
else
    [ -f "$NATIVE_HTML" ] || {
        printf 'Native Vergleichsausgabe fehlt: %s\n' "$NATIVE_HTML" >&2
        exit 2
    }
fi

# shellcheck disable=SC2086
python3 scripts/compare_full_all_html.py "$PYTHON_HTML" "$NATIVE_HTML" $COMPARE_ARGS
if [ "$KEEP" = 1 ]; then
    printf 'Ausgaben behalten unter %s\n' "$TMP"
fi
