#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# The user invokes this script after the production build. No build script
# compiles tests implicitly; these three focused targets reproduce the reported
# Mojo-1.0 default-argument failure and its two neighbouring runtime boundaries.
"$ROOT/scripts/test_stage12c5ar.sh"

for test_file in \
    tests/test_parallel_execution_config.mojo \
    tests/test_program_workflow.mojo \
    tests/test_legacy_reta_program.mojo
do
    name=$(basename "$test_file" .mojo)
    printf '\n== build %s ==\n' "$test_file"
    "$MOJO" build -I src -I tests "$test_file" -o "$TARGET/${name}_12c5as"
    printf '== run %s_12c5as ==\n' "$name"
    "$ROOT/bin/mojo-runtime-exec" "$TARGET/${name}_12c5as"
done

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_parallel_runtime_boundaries_source.py \
    tests/test_legacy_reta_program_source.py \
    tests/test_program_workflow_source.py \
    tests/test_all_columns_plan.py \
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
printf '%s\n' 'stage12c5as runtime-safe parallel configuration boundaries complete'
