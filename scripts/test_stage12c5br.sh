#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
if [ "${1:-}" = "--" ]; then
    shift
fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5bq.sh" -- "$@"
else
    printf '\n== corrected component-local fraction assertions ==\n'
    "$ROOT/scripts/check_prompt_true_fraction_multiples.sh" -- "$@"
fi

printf '\n== complete prompt output-parameter ownership and Python argv order ==\n'
"$ROOT/scripts/check_prompt_output_parameters.sh" -- "$@"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5br_source.py \
    tests/test_prompt_output_parameter_ownership_source.py \
    tests/test_architecture_probe_assets_source.py \
    tests/test_stage12c5bq_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5br complete prompt output-parameter ownership and set-order contract complete'
