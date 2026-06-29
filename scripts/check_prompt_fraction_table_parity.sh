#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
PROMPT=${RETA_PROMPT_NATIVE:-target/bin/reta-prompt-native}
RETA=${RETA_NATIVE:-target/bin/reta-native}
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/bin target/tests/prompt_fraction_tables
if [ ! -x "$RETA" ]; then
    "$MOJO" build -I src src/reta_native_main.mojo -o "$RETA"
fi
if [ ! -x "$PROMPT" ]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi

normalize_csv_payload() {
    python - "$1" "$2" <<'PY'
from pathlib import Path
import sys
source = Path(sys.argv[1]).read_bytes()
normalized = []
for line in source.splitlines():
    if line.startswith(b"reta ") or not line.strip():
        continue
    # Python's legacy renderers retain several presentation-only whitespace
    # runs. Compare the ordered CSV token stream after whitespace normalization.
    normalized.append(
        b"\x1f".join(b" ".join(field.split()) for field in line.split(b";"))
    )
Path(sys.argv[2]).write_bytes(
    b"\n".join(normalized) + (b"\n" if normalized else b"")
)
PY
}

check() {
    local name=$1; shift
    local raw="target/tests/prompt_fraction_tables/${name}.raw"
    local actual="target/tests/prompt_fraction_tables/${name}.actual"
    "$PROMPT" rpb "$@" --art=csv --nocolor > "$raw"
    normalize_csv_payload "$raw" "$actual"
    cmp "tests/fixtures/prompt_fraction_tables/${name}.expected" "$actual"
}

REQUESTED_COUNT=$#
requested=" $* "
run_case() {
    local name=$1; shift
    if [ "$REQUESTED_COUNT" -eq 0 ] || [[ "$requested" == *" $name "* ]]; then
        check "$name" "$@"
        CHECKED=$((CHECKED + 1))
    fi
}
CHECKED=0
run_case emotion-proper emotion 2/3
run_case emotion-reduced emotion 2/4
run_case universe-equal universum 3/3
run_case size-reduced groesse 2/4
run_case moon-divisors teiler mond 12
run_case moon-single einzeln mond 2
run_case moon-multiples vielfache mond 512
run_case motives-proper motive 2/3
run_case universe-rectangle universum 1/2-3/3
run_case motives-offset motive 4/5+2/2
printf 'native fraction/modifier prompt CSV token streams: %s/%s identical\n' "$CHECKED" "$CHECKED"
