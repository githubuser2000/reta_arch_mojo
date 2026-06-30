#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
RETA=${RETA_NATIVE:-"$ROOT/target/bin/reta-native"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
PYTHON=${PYTHON_BIN:-python3}
DEADLINE="$ROOT/scripts/run_with_deadline.py"
OUT=${PROPERTY_PARITY_OUT:-"$ROOT/target/tests/prompt_properties"}
mkdir -p "$(dirname "$RETA")" "$OUT"
if [[ ! -x "$RETA" ]]; then
    "$MOJO" build -I src src/reta_native_main.mojo -o "$RETA"
fi
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi

"$PYTHON" - <<'PY'
import csv
from pathlib import Path

US = "\x1f"
properties = []
with Path("assets/prompt_nested_completion.tsv").open(
    encoding="utf-8", newline=""
) as handle:
    for language, scope, _context, values in csv.reader(handle, delimiter="\t"):
        if language == "deutsch" and scope == "root":
            properties.extend(
                value
                for value in values.split(US)
                if value.startswith(("EIGN", "EIGR"))
            )

aliases = set()
with Path("assets/generated_aliases.tsv").open(
    encoding="utf-8", newline=""
) as handle:
    for row in csv.reader(handle, delimiter="\t"):
        if len(row) >= 3 and row[0] == "german":
            aliases.add((row[1], row[2]))
with Path("assets/parameter_aliases.tsv").open(
    encoding="utf-8", newline=""
) as handle:
    for row in csv.reader(handle, delimiter="\t"):
        if len(row) >= 2:
            aliases.add((row[0], row[1]))

assert len(properties) == 165, len(properties)
for value in properties:
    parameter = "konzept" if value.startswith("EIGN") else "konzept2"
    assert (parameter, value[4:]) in aliases, value
print("PASS property catalog aliases (165/165)")
PY

normalize_csv() {
    timeout --signal=KILL 30 "$PYTHON" - "$1" "$2" <<'PY'
from pathlib import Path
import sys
rows = []
for line in Path(sys.argv[1]).read_bytes().splitlines():
    if not line.strip() or b";" not in line:
        continue
    rows.append(
        b"\x1f".join(b" ".join(field.split()) for field in line.split(b";"))
    )
Path(sys.argv[2]).write_bytes(
    b"\n".join(rows) + (b"\n" if rows else b"")
)
PY
}

check() {
    local name=$1
    shift
    "$DEADLINE" 90 "$OUT/$name.python" -- \
        env PYTHONHASHSEED=0 "$PYTHON" python_reference/reta.py "$@"
    "$DEADLINE" 90 "$OUT/$name.mojo" -- "$RETA" "$@"
    normalize_csv "$OUT/$name.python" "$OUT/$name.python.normalized"
    normalize_csv "$OUT/$name.mojo" "$OUT/$name.mojo.normalized"
    cmp "$OUT/$name.python.normalized" "$OUT/$name.mojo.normalized"
    printf 'PASS %s (%s normalized bytes)\n' \
        "$name" "$(wc -c < "$OUT/$name.mojo.normalized")"
}

check eign-single \
    -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025 \
    -spalten --konzept=gut --breite=0 \
    -ausgabe --art=csv --nocolor
check eign-set-order \
    -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025 \
    -spalten --konzept=ehrlich,gut --breite=0 \
    -ausgabe --art=csv --nocolor
check eigr-integer \
    -zeilen --vorhervonausschnitt=0 \
    -spalten --konzept2=werte --breite=0 \
    -ausgabe --nocolor --art=csv \
    -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025
check eigr-reciprocal \
    -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025 \
    -spalten --konzept2=werte --breite=0 \
    -ausgabe --nocolor --art=csv
check eigr-mixed \
    -zeilen --vorhervonausschnitt=3 --oberesmaximum=1025 \
    -spalten --konzept2=werte --breite=0 \
    -ausgabe --nocolor --art=csv \
    -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025
printf '%s\n' 'native EIGN/EIGR table streams: 5/5 semantically identical'

check_prompt() {
    local name=$1
    shift
    "$DEADLINE" 90 "$OUT/$name.python" -- \
        env PYTHONHASHSEED=0 "$PYTHON" python_reference/rpb "$@"
    "$DEADLINE" 90 "$OUT/$name.mojo" -- "$PROMPT" rpb "$@"
    normalize_csv "$OUT/$name.python" "$OUT/$name.python.normalized"
    normalize_csv "$OUT/$name.mojo" "$OUT/$name.mojo.normalized"
    cmp "$OUT/$name.python.normalized" "$OUT/$name.mojo.normalized"
    printf 'PASS %s prompt payload (%s normalized bytes)\n' \
        "$name" "$(wc -c < "$OUT/$name.mojo.normalized")"
}

check_prompt eign-prompt-single EIGNgut 2 --art=csv --nocolor
check_prompt eign-prompt-set-order \
    EIGNgut EIGNehrlich 2 --art=csv --nocolor
printf '%s\n' 'native EIGN prompt payloads: 2/2 semantically identical'
