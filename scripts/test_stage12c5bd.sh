#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve the installed-launcher and complete true-fraction runtime/parity
# chain first.  The inherited chain recompiles prompt_table_execution.mojo and
# executes the direct 13-invocation reciprocal-collision contract.
"$ROOT/scripts/test_stage12c5bc.sh"

printf '\n== build tests/test_presheaves_complete.mojo ==\n'
"$MOJO" build --no-optimization -j 4 -I src -I tests \
    tests/test_presheaves_complete.mojo \
    -o "$TARGET/test_presheaves_complete_12c5bd"
printf '== run test_presheaves_complete_12c5bd ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    "$TARGET/test_presheaves_complete_12c5bd"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_presheaf_inheritance_source.py \
    tests/test_prompt_reciprocal_collision_source.py \
    tests/test_stage12c5bd_source.py \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bd presheaf neutral-section inheritance and native reciprocal collision'
