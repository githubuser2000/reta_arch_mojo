#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

"$MOJO" build -I src tests/test_prompt_interaction.mojo \
    -o target/tests/test_prompt_interaction_12c5a
python3 tools/sanitize_mojo_runpath.py \
    target/tests/test_prompt_interaction_12c5a >/dev/null
target/tests/test_prompt_interaction_12c5a

scripts/check_prompt_session_parity.sh
python3 -m pytest -q \
    tests/test_prompt_interaction_source.py \
    tests/test_prompt_session_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py

if [ "${RETA_BUILD_PROMPT:-0}" = 1 ]; then
    "$MOJO" build -I src src/prompt_main.mojo \
        -Xlinker -rpath -Xlinker '$ORIGIN/../lib/mojo' \
        -o target/bin/reta-prompt-native
    python3 tools/sanitize_mojo_runpath.py \
        target/bin/reta-prompt-native >/dev/null
    scripts/test_prompt_bins.sh
    scripts/check_prompt_session_pty_prefix.py target/bin/reta-prompt-native
else
    printf '%s\n' \
        'Produktiver Promptbuild: RETA_BUILD_PROMPT=1 scripts/test_stage12c5a.sh'
fi
