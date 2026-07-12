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
    "$ROOT/scripts/test_stage12c5fo.sh" -- "$@"
fi

printf '\n== core shared ABI thin starter ==\n'
"$ROOT/scripts/build_core_shared.sh" --dry-run -- "$@"
# explicit source name kept for source guards: tests/test_shared_library_architecture.mojo
for test_name in shared_library_architecture legacy_reta_program prompt_execution; do
    printf '\n== build tests/test_%s.mojo ==\n' "$test_name"
    "$MOJO" build -I src -I tests "tests/test_${test_name}.mojo" "$@" \
        -o "$TARGET/test_${test_name}_12c5fp"
    printf '== run test_%s_12c5fp ==\n' "$test_name"
    "$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_${test_name}_12c5fp"
done

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5fp_source.py \
    tests/test_core_shared_library_source.py \
    tests/test_stage12c5fo_source.py \
    tests/test_stage12c5fn_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5fp core shared ABI thin starter complete'
