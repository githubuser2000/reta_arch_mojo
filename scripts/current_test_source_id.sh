#!/usr/bin/env sh
# Compute a content ID for every input that can change a compiled Mojo test.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp "${TMPDIR:-/tmp}/reta-test-build-inputs.XXXXXX")
trap 'rm -f "$TMP"' EXIT HUP INT TERM

{
    find src tests assets -type f ! -path '*/__pycache__/*' ! -name '*.pyc' -print0 2>/dev/null || true
    printf '%s\0' \
        scripts/build-tests.sh \
        scripts/run-tests.sh \
        scripts/current_test_source_id.sh \
        scripts/configure_mojo_runtime.sh \
        scripts/mojo_build_options.sh \
        tools/run_mojo_test_binaries.py \
        bin/mojo-real
} | LC_ALL=C sort -zu | xargs -0 sha256sum > "$TMP"

find src tests assets -type l -printf '%p -> %l\n' 2>/dev/null \
    | LC_ALL=C sort >> "$TMP" || true

sha256sum "$TMP" | awk '{print $1}'
