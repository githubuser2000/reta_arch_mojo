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
    "$ROOT/scripts/test_stage12c5fm.sh" -- "$@"
fi

printf '\n== prompt execution native completion ==\n'
for test_name in prompt_execution prompt_table_execution prompt_interaction architecture_progress architecture_boundaries; do
    printf '\n== build tests/test_%s.mojo ==\n' "$test_name"
    "$MOJO" build -I src -I tests "tests/test_${test_name}.mojo" "$@" \
        -o "$TARGET/test_${test_name}_12c5fn"
    printf '== run test_%s_12c5fn ==\n' "$test_name"
    "$ROOT/bin/mojo-runtime-exec" "$TARGET/test_${test_name}_12c5fn"
done

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5fn_source.py \
    tests/test_prompt_execution_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_stage12c5fm_source.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5fn prompt execution native completion complete'
# current-stage history for source contracts: test_stage12c5fn.sh test_stage12c5fm.sh test_stage12c5fl.sh test_stage12c5fk.sh test_stage12c5fj.sh test_stage12c5fi.sh
