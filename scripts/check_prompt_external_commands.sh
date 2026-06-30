#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"

"$ROOT/bin/mojo-real" build -I src \
    tests/test_prompt_external_commands.mojo \
    -o "$TEST_DIR/test-prompt-external-commands"
"$TEST_DIR/test-prompt-external-commands"

"$ROOT/bin/mojo-real" build -I src \
    tests/prompt_external_commands_probe.mojo \
    -o "$TEST_DIR/prompt-external-commands-probe"

"$ROOT/bin/mojo-real" build -I src \
    tests/test_prompt_raw_commands.mojo \
    -o "$TEST_DIR/test-prompt-raw-commands"
"$TEST_DIR/test-prompt-raw-commands"

python3 -m pytest -q \
    tests/test_prompt_external_commands.py \
    tests/test_prompt_external_source.py \
    tests/test_native_boundary_audit.py
