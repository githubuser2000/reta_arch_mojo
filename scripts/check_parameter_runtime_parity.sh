#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=${RETA_PYTHON-}
if [ -z "$PYTHON" ]; then
    if [ -x "$ROOT/.venv/bin/python" ]; then
        PYTHON="$ROOT/.venv/bin/python"
    else
        PYTHON=$(command -v python3)
    fi
fi
PROBE=target/tests/parameter_runtime_probe
"$MOJO" build -I src tests/parameter_runtime_probe.mojo -o "$PROBE"
python3 tools/sanitize_mojo_runpath.py "$PROBE" >/dev/null
set -- \
  --oberesmaximum=17 \
  --oberesmaximum=x \
  --vorhervonausschnitt=1-3 \
  --vorhervonausschnitt=1024-1025 \
  --vorhervonausschnitt=v2-4 \
  --foo=2
PYTHONHASHSEED=0 "$PYTHON" scripts/parameter_runtime_reference.py "$@" > target/tests/parameter_runtime.python
"$PROBE" "$@" > target/tests/parameter_runtime.mojo
"$PYTHON" scripts/compare_parameter_runtime_parity.py \
  target/tests/parameter_runtime.python target/tests/parameter_runtime.mojo
