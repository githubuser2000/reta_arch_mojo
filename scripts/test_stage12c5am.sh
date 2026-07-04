#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# 12c5al has not yet been confirmed by the user's Modular compiler. Keep its
# reproducibility and full legacy-I18n checks as a prerequisite for this stage.
"$ROOT/scripts/test_stage12c5al.sh"

printf '\n== generate/check exact legacy retaPrompt catalog ==\n'
PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_legacy_reta_prompt_catalog.py --check

printf '\n== build tests/test_legacy_reta_prompt.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_legacy_reta_prompt.mojo \
    -o "$TARGET/test_legacy_reta_prompt_12c5am"
printf '== run test_legacy_reta_prompt_12c5am ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_legacy_reta_prompt_12c5am"

printf '\n== build tests/test_generated_columns_integration.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_generated_columns_integration.mojo \
    -o "$TARGET/test_generated_columns_integration_12c5am"
printf '== run test_generated_columns_integration_12c5am ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_generated_columns_integration_12c5am"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_legacy_reta_prompt_source.py \
    tests/test_prompt_interaction_source.py \
    tests/test_generated_columns_registry_source.py \
    tests/test_generated_columns_integration_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_install_target_manifest.py \
    tests/test_stage_build_separation.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5am complete native retaPrompt facade and generated-column integration'
