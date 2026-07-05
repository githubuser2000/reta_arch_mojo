#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ "${1:-}" = "--" ]; then
    shift
fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
BINARY="$TEST_DIR/prompt-true-fraction-multiple-probe"
if mojo_has_thread_option "$@"; then
    "$MOJO" build --no-optimization -I src \
        tests/prompt_true_fraction_multiple_probe.mojo "$@" -o "$BINARY"
else
    "$MOJO" build --no-optimization -j 4 -I src \
        tests/prompt_true_fraction_multiple_probe.mojo -o "$BINARY"
fi
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" scripts/check_prompt_true_fraction_multiples.py \
    "$BINARY" "$ROOT/bin/reta-native"
