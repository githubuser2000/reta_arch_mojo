#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/prompt_fraction_probe.mojo -o target/tests/prompt-fraction-probe
cases=(
  '1/2' 'abc1/2def' '1/2+3/4' '1/2-3/4' '2/3-5/7' '2/3x4/5'
  '10/20' 'x12/3y' '4/2+1/3' '4/2-6/5' '7/9abc2/3' '1abc/2def'
  '1/2/3' '2/3+4' 'foo' '0/1' '12/4-15/5' '3/7+2/9'
)
PY=${RETA_REFERENCE_PYTHON:-"$ROOT/.venv/bin/python"}
[ -x "$PY" ] || PY=python3
PYTHONHASHSEED=0 "$PY" scripts/prompt_fraction_reference.py "${cases[@]}" > target/tests/prompt-fraction-python
./target/tests/prompt-fraction-probe "${cases[@]}" > target/tests/prompt-fraction-mojo
if ! cmp target/tests/prompt-fraction-python target/tests/prompt-fraction-mojo; then
  diff -u target/tests/prompt-fraction-python target/tests/prompt-fraction-mojo || true
  exit 1
fi
printf 'prompt fraction parity: %s/%s cases byte-identical\n' "${#cases[@]}" "${#cases[@]}"
