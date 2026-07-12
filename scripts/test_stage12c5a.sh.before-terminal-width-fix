#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
BIN_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}

"$MOJO" build -I src tests/test_prompt_interaction.mojo \
    -o target/tests/test_prompt_interaction_12c5a
python3 tools/sanitize_mojo_runpath.py \
    target/tests/test_prompt_interaction_12c5a >/dev/null
target/tests/test_prompt_interaction_12c5a

scripts/check_prompt_session_parity.sh
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_prompt_interaction_source.py \
    tests/test_prompt_session_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py

"$ROOT/scripts/require_built_targets.sh" scripts/build.sh reta-prompt-native
scripts/test_prompt_bins.sh
scripts/check_prompt_session_pty_prefix.py "$BIN_DIR/reta-prompt-native"
