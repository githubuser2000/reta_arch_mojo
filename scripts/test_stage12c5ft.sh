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
    "$ROOT/scripts/test_stage12c5fs.sh" -- "$@"
fi

printf '\n== prompt shared ABI thin starters ==\n'
"$ROOT/scripts/build_prompt_shared.sh" --dry-run -- "$@"
"$ROOT/scripts/build_shared_library_targets.sh" --dry-run -- "$@"

# Explicit source names kept for guards: tests/test_shared_library_architecture.mojo test_shared_library_architecture_12c5ft
for test_name in shared_library_architecture; do
    printf '\n== build tests/test_%s.mojo ==\n' "$test_name"
    "$MOJO" build -I src -I tests "tests/test_${test_name}.mojo" "$@" \
        -o "$TARGET/test_${test_name}_12c5ft"
    printf '== run test_%s_12c5ft ==\n' "$test_name"
    "$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_${test_name}_12c5ft"
done

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5ft_source.py \
    tests/test_prompt_shared_library_source.py \
    tests/test_stage12c5fs_source.py \
    tests/test_stage12c5fr_source.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ft prompt shared ABI thin starters complete'
