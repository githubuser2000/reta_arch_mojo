#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/test_completion_runtime.mojo -o target/tests/test_completion_runtime
"$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null
python3 "$ROOT/tools/sanitize_mojo_runpath.py" target/tests/test_completion_runtime >/dev/null
target/tests/test_completion_runtime
