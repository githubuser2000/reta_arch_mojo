#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/reta_build_defaults.sh"
reta_build_set_defaults
reta_build_validate_defaults

exec cmake -S . -B "$RETA_CMAKE_BUILD_DIR" -G "$RETA_CMAKE_GENERATOR" \
    -DRETA_MOJO_JOBS="$RETA_MOJO_JOBS" \
    -DRETA_TEST_RUN_JOBS="$RETA_TEST_RUN_JOBS" \
    -DRETA_TEST_RUN_TIMEOUT="$RETA_TEST_RUN_TIMEOUT" \
    "$@"
