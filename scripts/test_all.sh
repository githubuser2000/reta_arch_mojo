#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
for test_file in tests/test_*.mojo; do
    printf '\n== %s ==\n' "$test_file"
    "$ROOT/bin/mojo-real" run -I src "$test_file"
done
