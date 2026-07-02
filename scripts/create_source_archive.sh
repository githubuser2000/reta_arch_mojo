#!/usr/bin/env sh
# Create and verify a source-only reta_arch_mojo archive.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PARENT=$(dirname -- "$ROOT")
NAME=$(basename -- "$ROOT")
OUT=${1:-"$PARENT/${NAME}_source.tar.bz2"}
case "$OUT" in
    /*) ;;
    *) OUT=$(pwd)/$OUT ;;
esac
case "$OUT" in
    *.tar.bz2|*.tbz2) FORMAT=bz2 ;;
    *.tar.br|*.tbr|*.tar.brotli) FORMAT=br ;;
    *.tar.xz|*.txz) FORMAT=xz ;;
    *.tar) FORMAT=tar ;;
    *)
        printf '%s\n' 'Unterstützte Endungen: .tar.xz, .txz, .tar.bz2, .tbz2, .tar.br, .tbr, .tar.brotli, .tar' >&2
        exit 64
        ;;
esac
mkdir -p "$(dirname -- "$OUT")"

"$ROOT/scripts/update_source_manifest.sh"
TMP_BASE="$OUT.tmp.$$"
TMP_TAR="$TMP_BASE.tar"
TMP_ARCHIVE="$TMP_BASE.archive"
TMP_VERIFY="$TMP_BASE.verify.tar"
rm -f -- "$TMP_TAR" "$TMP_ARCHIVE" "$TMP_VERIFY"
trap 'rm -f -- "$TMP_TAR" "$TMP_ARCHIVE" "$TMP_VERIFY"' EXIT HUP INT TERM
cd "$PARENT"
tar -cf "$TMP_TAR" \
    --exclude="$NAME/.venv" \
    --exclude="$NAME/target" \
    --exclude="$NAME/build" \
    --exclude="$NAME/.git" \
    --exclude='*/.pytest_cache' \
    --exclude='*/__pycache__' \
    --exclude='*.pyc' \
    --exclude='*.pyo' \
    --exclude="$NAME/middle.alx" \
    "$NAME"

case "$FORMAT" in
    bz2)
        bzip2 -9 -c "$TMP_TAR" > "$TMP_ARCHIVE"
        LIST_TAR="$TMP_TAR"
        ;;
    br)
        BROTLI_QUALITY=${RETA_BROTLI_QUALITY:-9}
        python3 "$ROOT/tools/brotli_file.py" compress "$TMP_TAR" "$TMP_ARCHIVE" --quality "$BROTLI_QUALITY"
        python3 "$ROOT/tools/brotli_file.py" decompress "$TMP_ARCHIVE" "$TMP_VERIFY"
        cmp "$TMP_TAR" "$TMP_VERIFY"
        LIST_TAR="$TMP_VERIFY"
        ;;
    xz)
        XZ_THREADS=${RETA_XZ_THREADS:-0}
        XZ_LEVEL=${RETA_XZ_LEVEL:-9e}
        xz -T"$XZ_THREADS" -"$XZ_LEVEL" -c "$TMP_TAR" > "$TMP_ARCHIVE"
        xz -d -c "$TMP_ARCHIVE" > "$TMP_VERIFY"
        cmp "$TMP_TAR" "$TMP_VERIFY"
        LIST_TAR="$TMP_VERIFY"
        ;;
    tar)
        cp "$TMP_TAR" "$TMP_ARCHIVE"
        LIST_TAR="$TMP_TAR"
        ;;
esac

FORBIDDEN='(^|/)(\.venv|target|build|\.git|\.pytest_cache|__pycache__)(/|$)|\.py[co]$|/middle\.alx$|prompt_python_bridge\.mojo$'
if tar -tf "$LIST_TAR" | grep -E "$FORBIDDEN" >/dev/null; then
    printf '%s\n' 'Sourcearchiv enthält verbotene Build-, Cache- oder Bridge-Dateien.' >&2
    tar -tf "$LIST_TAR" | grep -E "$FORBIDDEN" >&2 || true
    exit 1
fi
mv -f -- "$TMP_ARCHIVE" "$OUT"
trap - EXIT HUP INT TERM
rm -f -- "$TMP_TAR" "$TMP_VERIFY"
printf 'Sourcearchiv: %s\n' "$OUT"
printf 'SHA-256: '
sha256sum "$OUT" | awk '{print $1}'
printf 'Bytes: '
wc -c < "$OUT" | tr -d ' '
