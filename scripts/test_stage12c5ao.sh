#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Keep the complete 12c5an chain, including the previously failing
# GeneratedColumnsApplicationRequest ownership test, as a prerequisite.
"$ROOT/scripts/test_stage12c5an.sh"

printf '\n== generate/check exact legacy reta.py catalog ==\n'
PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_legacy_reta_program_catalog.py --check

printf '\n== build tests/test_legacy_reta_program.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_legacy_reta_program.mojo \
    -o "$TARGET/test_legacy_reta_program_12c5ao"
printf '== run test_legacy_reta_program_12c5ao ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_legacy_reta_program_12c5ao"

printf '\n== generate/check exact setup.py metadata ==\n'
PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_setup_metadata.py --check

printf '\n== build tests/test_setup_metadata.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_setup_metadata.mojo \
    -o "$TARGET/test_setup_metadata_12c5ao"
printf '== run test_setup_metadata_12c5ao ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_setup_metadata_12c5ao"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_generated_columns_integration_source.py \
    tests/test_legacy_reta_program_source.py \
    tests/test_setup_metadata_source.py \
    tests/test_program_workflow_source.py \
    tests/test_install_target_manifest.py \
    tests/test_install_layout.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_stage_build_separation.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ao complete CsvTable ownership, typed reta.py facade and native setup metadata'
