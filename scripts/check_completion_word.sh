#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
"$ROOT/bin/mojo-real" build -I src -I tests \
    tests/test_completion_word.mojo -o "$TEST_DIR/test-completion-word"
python3 "$ROOT/tools/sanitize_mojo_runpath.py" \
    "$TEST_DIR/test-completion-word" >/dev/null
"$ROOT/bin/mojo-runtime-exec" "$TEST_DIR/test-completion-word"
python3 scripts/check_completion_word_parity.py
