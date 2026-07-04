#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")

# All compiler and runtime checks remain in the user-owned preceding stage.
"$ROOT/scripts/test_stage12c5av.sh"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_legacy_reta_program_source.py \
    tests/test_build_compiler_options.py \
    tests/test_legacy_reta_program_startup_source.py \
    tests/test_parallel_runtime_boundaries_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5aw monotonic legacy upper limit and configurable builds'
