#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"

"$ROOT/bin/mojo-real" build -I src \
    tests/test_native_prompt_input.mojo \
    -o "$TEST_DIR/test-native-prompt-input"
"$TEST_DIR/test-native-prompt-input"


"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_prompt_line_editor.mojo \
    -o "$TEST_DIR/test-prompt-line-editor"
"$TEST_DIR/test-prompt-line-editor"

"$ROOT/bin/mojo-real" build -I src \
    tests/native_prompt_input_probe.mojo \
    -o "$TEST_DIR/native-prompt-input-probe"


"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/prompt_native_tty_probe.mojo \
    -o "$TEST_DIR/prompt-native-tty-probe"

mkdir -p "$ROOT/target/tests"
cp "$TEST_DIR/native-prompt-input-probe" \
    "$ROOT/target/tests/native-prompt-input-probe"

python3 -m pytest -q \
    tests/test_native_prompt_input.py \
    tests/test_prompt_native_tty.py \
    tests/test_prompt_native_input_source.py \
    tests/test_native_boundary_audit.py
