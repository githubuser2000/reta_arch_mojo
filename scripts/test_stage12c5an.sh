#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Keep the not-yet-locally-confirmed 12c5am stage as an explicit prerequisite.
"$ROOT/scripts/test_stage12c5am.sh"

printf '\n== build tests/test_parameter_semantics.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_parameter_semantics.mojo \
    -o "$TARGET/test_parameter_semantics_12c5an"
printf '== run test_parameter_semantics_12c5an ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_parameter_semantics_12c5an"

printf '\n== generate/check exact legacy mojo_bridge catalog ==\n'
PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_legacy_mojo_bridge_catalog.py --check

printf '\n== build tests/test_legacy_mojo_bridge.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_legacy_mojo_bridge.mojo \
    -o "$TARGET/test_legacy_mojo_bridge_12c5an"
printf '== run test_legacy_mojo_bridge_12c5an ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_legacy_mojo_bridge_12c5an"

printf '\n== build tests/test_parameter_runtime_complete.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_parameter_runtime_complete.mojo \
    -o "$TARGET/test_parameter_runtime_complete_12c5an"
printf '== run test_parameter_runtime_complete_12c5an ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_parameter_runtime_complete_12c5an"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_legacy_mojo_bridge_source.py \
    tests/test_parameter_runtime_complete_source.py \
    tests/test_parameter_runtime_source.py \
    tests/test_prompt_external_source.py \
    tests/test_generate_html_source_contract.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_install_target_manifest.py \
    tests/test_stage_build_separation.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5an complete native mojo_bridge facade and parameter runtime'
