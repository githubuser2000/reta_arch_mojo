#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"
if [ "${1:-}" = "--" ]; then shift; fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5bx.sh" -- "$@"
fi

printf '\n== legacy prompt scope follows interaction ownership ==\n'
for test_name in legacy_reta_prompt prompt_interaction; do
    printf '\n== build tests/test_%s.mojo ==\n' "$test_name"
    "$MOJO" build -I src -I tests "tests/test_${test_name}.mojo" "$@" \
        -o "$TARGET/test_${test_name}_12c5by"
    printf '== run test_%s_12c5by ==\n' "$test_name"
    "$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_${test_name}_12c5by"
done

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5by_source.py \
    tests/test_stage12c5bx_source.py \
    tests/test_legacy_reta_prompt_source.py \
    tests/test_prompt_interaction_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5by legacy prompt scope ownership complete'
