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
    "$ROOT/scripts/test_stage12c5bi.sh" -- "$@"
fi

printf '\n== check pinned command parity assets without renderer execution ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_command_parity_assets.py --check

printf '\n== compile/run corrected fraction divisor probe ==\n'
"$ROOT/scripts/check_prompt_true_fraction_multiples.sh" -- "$@"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_command_parity_asset_environment.py \
    tests/test_command_parity_native_source.py \
    tests/test_stage12c5bg_source.py \
    tests/test_stage12c5bh_source.py \
    tests/test_stage12c5bi_source.py \
    tests/test_stage12c5bj_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bj pinned command-parity gate and typed fraction-divisor compile boundary complete'
