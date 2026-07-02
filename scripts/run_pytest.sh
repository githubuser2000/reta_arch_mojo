#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
exec "$TEST_PYTHON" -m pytest "$@"
