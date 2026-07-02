#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
OUT=${1:-"$ROOT/target/references/reta-python-full-all-reference.tar.bz2"}
WORK=${RETA_FULL_ALL_REFERENCE_WORKDIR:-"$ROOT/target/references/full-all-work"}
SOURCE_HTML=${RETA_FULL_ALL_HTML-}
REFERENCE_HASHSEED=${RETA_FULL_ALL_PYTHONHASHSEED-}
mkdir -p "$WORK" "$(dirname -- "$OUT")"
HTML="$WORK/python-all.html"
TIME_FILE="$WORK/python.time"
META="$WORK/metadata.txt"
ARGS='-spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor'
if [ -n "$SOURCE_HTML" ]; then
    cp "$SOURCE_HTML" "$HTML"
    [ -n "$REFERENCE_HASHSEED" ] || REFERENCE_HASHSEED=uncontrolled
    printf '%s
' 'python_seconds=provided' 'python_max_rss_kib=provided' > "$TIME_FILE"
else
    [ -n "$REFERENCE_HASHSEED" ] || REFERENCE_HASHSEED=0
    # shellcheck disable=SC2086
    PYTHONHASHSEED=$REFERENCE_HASHSEED /usr/bin/time -f 'python_seconds=%e
python_max_rss_kib=%M' -o "$TIME_FILE" \
        "$PYTHON" python_reference/reta.py $ARGS > "$HTML"
fi
{
    printf 'format=reta-full-all-reference-v1\n'
    printf 'command=python_reference/reta.py %s\n' "$ARGS"
    printf 'pythonhashseed=%s\n' "$REFERENCE_HASHSEED"
    printf 'python_executable=%s\n' "$PYTHON"
    "$PYTHON" --version 2>&1 | sed 's/^/python_version=/'
    printf 'sha256='; sha256sum "$HTML" | awk '{print $1}'
    printf 'bytes='; wc -c < "$HTML" | tr -d ' '
    printf 'lines='; wc -l < "$HTML" | tr -d ' '
    cat "$TIME_FILE"
} > "$META"
python3 - "$HTML" >> "$META" <<'PY'
from pathlib import Path
import sys
from scripts.compare_full_all_html import parse
table = parse(Path(sys.argv[1]))
print(f"table_rows={len(table.shape)}")
print(f"table_cells={len(table.records) // 96}")
PY
TMP_OUT="$OUT.tmp.$$"
tar -cjf "$TMP_OUT" -C "$WORK" python-all.html metadata.txt python.time
mv "$TMP_OUT" "$OUT"
printf 'Referenzpaket: %s\n' "$OUT"
cat "$META"
