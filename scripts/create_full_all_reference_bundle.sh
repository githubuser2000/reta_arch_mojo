#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
PYTHON=${RETA_PYTHON-}
if [ -z "$PYTHON" ]; then
    if [ -x "$ROOT/.venv/bin/python" ]; then
        PYTHON="$ROOT/.venv/bin/python"
    else
        PYTHON=$(command -v python3)
    fi
fi
OUT=${1:-"$ROOT/target/references/reta-python-full-all-reference.tar.bz2"}
WORK=${RETA_FULL_ALL_REFERENCE_WORKDIR:-"$ROOT/target/references/full-all-work"}
SOURCE_HTML=${RETA_FULL_ALL_HTML-}
mkdir -p "$WORK" "$(dirname -- "$OUT")"
HTML="$WORK/python-all.html"
TIME_FILE="$WORK/python.time"
META="$WORK/metadata.txt"
ARGS='-spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor'
if [ -n "$SOURCE_HTML" ]; then
    cp "$SOURCE_HTML" "$HTML"
    printf '%s\n' 'python_seconds=provided' 'python_max_rss_kib=provided' > "$TIME_FILE"
else
    # shellcheck disable=SC2086
    PYTHONHASHSEED=0 /usr/bin/time -f 'python_seconds=%e\npython_max_rss_kib=%M' -o "$TIME_FILE" \
        "$PYTHON" python_reference/reta.py $ARGS > "$HTML"
fi
{
    printf 'format=reta-full-all-reference-v1\n'
    printf 'command=python_reference/reta.py %s\n' "$ARGS"
    printf 'pythonhashseed=0\n'
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
