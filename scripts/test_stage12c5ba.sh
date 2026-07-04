#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")

# Preserve the complete mixed-fraction runtime/parity gate first.  This
# recompiles the prompt table owner and therefore catches missing Mojo effect
# annotations such as the reported Int(String) `raises` boundary.
"$ROOT/scripts/test_stage12c5az.sh"

# The production build itself remains user-run.  These tests use a fake Mojo
# executable to prove exact option forwarding and the single-thread-option
# invariant without compiling native targets here.
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_build_compiler_options.py \
    tests/test_build_thread_option_dedup.py \
    tests/test_stage12c5ba_source.py \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5ba single compiler thread option, explicit raises, and native negative fraction no-ops'
