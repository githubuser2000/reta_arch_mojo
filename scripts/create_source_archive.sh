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
mkdir -p "$(dirname -- "$OUT")"

"$ROOT/scripts/update_source_manifest.sh"
TMP="$OUT.tmp.$$"
rm -f -- "$TMP"
trap 'rm -f -- "$TMP"' EXIT HUP INT TERM
cd "$PARENT"
tar -cjf "$TMP" \
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

FORBIDDEN='(^|/)(\.venv|target|build|\.git|\.pytest_cache|__pycache__)(/|$)|\.py[co]$|/middle\.alx$|prompt_python_bridge\.mojo$'
if tar -tjf "$TMP" | grep -E "$FORBIDDEN" >/dev/null; then
    printf '%s\n' 'Sourcearchiv enthält verbotene Build-, Cache- oder Bridge-Dateien.' >&2
    tar -tjf "$TMP" | grep -E "$FORBIDDEN" >&2 || true
    exit 1
fi
mv -f -- "$TMP" "$OUT"
trap - EXIT HUP INT TERM
printf 'Sourcearchiv: %s\n' "$OUT"
printf 'SHA-256: '
sha256sum "$OUT" | awk '{print $1}'
printf 'Bytes: '
wc -c < "$OUT" | tr -d ' '
