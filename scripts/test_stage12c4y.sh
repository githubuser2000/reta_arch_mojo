#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

"$MOJO" build -I src tests/test_parameter_runtime.mojo \
    -o target/tests/test_parameter_runtime_12c4y
python3 tools/sanitize_mojo_runpath.py target/tests/test_parameter_runtime_12c4y >/dev/null
target/tests/test_parameter_runtime_12c4y

"$MOJO" build -I src tests/test_native_reta_cli.mojo \
    -o target/tests/test_native_reta_cli_12c4y
python3 tools/sanitize_mojo_runpath.py target/tests/test_native_reta_cli_12c4y >/dev/null
target/tests/test_native_reta_cli_12c4y

scripts/check_parameter_runtime_parity.sh
for pytest_file in \
    tests/test_parameter_runtime_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_full_all_reference_workflow.py \
    tests/test_known_defects.py \
    tests/test_native_boundary_audit.py
 do
    python3 -m pytest -q "$pytest_file"
 done
python3 tools/check_known_defects.py

if [ -n "${RETA_FULL_ALL_REFERENCE-}" ]; then
    scripts/check_full_all_against_reference.sh "$RETA_FULL_ALL_REFERENCE"
elif [ "${RETA_RUN_FULL_ALL:-0}" = 1 ]; then
    scripts/check_full_all_parity.sh
else
    printf '%s\n' 'Vollständiges --alles-Gate: RETA_FULL_ALL_REFERENCE=/pfad/referenz.tar.bz2 scripts/test_stage12c4y.sh'
fi
