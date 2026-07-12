#!/usr/bin/env sh
set -eu


ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve the runtime-safe environment boundary and typed prompt execution.
"$ROOT/scripts/test_stage12c5at.sh"

printf '\n== build tests/test_legacy_reta_program_startup.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_legacy_reta_program_startup.mojo \
    -o "$TARGET/test_legacy_reta_program_startup_12c5au"
printf '== run test_legacy_reta_program_startup_12c5au ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    "$TARGET/test_legacy_reta_program_startup_12c5au"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_legacy_reta_program_startup_source.py \
    tests/test_legacy_reta_program_source.py \
    tests/test_parallel_runtime_boundaries_source.py \
    tests/test_prompt_execution_runtime_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_stage_build_separation.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5au native legacy reta startup and control ownership'
