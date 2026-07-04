#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve the complete historical-prompt ownership gate first.
"$ROOT/scripts/test_stage12c5ax.sh"

printf '\n== build tests/test_parallel_number_processes.mojo ==\n'
"$MOJO" build -I src -I tests \
    tests/test_parallel_number_processes.mojo \
    -o "$TARGET/test_parallel_number_processes_12c5ay"
printf '== run test_parallel_number_processes_12c5ay ==\n'
"$ROOT/bin/mojo-runtime-exec" \
    "$TARGET/test_parallel_number_processes_12c5ay"

printf '\n== build tests/test_parallel_row_processes.mojo ==\n'
"$MOJO" build -I src -I tests \
    tests/test_parallel_row_processes.mojo \
    -o "$TARGET/test_parallel_row_processes_12c5ay"
printf '== run test_parallel_row_processes_12c5ay ==\n'
"$ROOT/bin/mojo-runtime-exec" \
    "$TARGET/test_parallel_row_processes_12c5ay"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_parallel_process_alias_source.py \
    tests/test_parallel_runtime_boundaries_source.py \
    tests/test_stage_build_separation.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5ay thread-only legacy process aliases and native prompt families'
