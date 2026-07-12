#!/usr/bin/env sh
set -eu


ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")

# Preserve the complete build-thread, effect-signature and mixed-fraction
# runtime/parity chain first.  This recompiles the prompt table owner and runs
# the direct native invocation checker when the user executes this stage.
"$ROOT/scripts/test_stage12c5ba.sh"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_stage12c5bb_source.py \
    tests/test_prompt_execution_source.py \
    tests/test_prompt_execution_runtime_source.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bb positive-first reciprocal multiples with excluded true fractions'
