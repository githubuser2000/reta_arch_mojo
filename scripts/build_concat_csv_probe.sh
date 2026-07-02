#!/usr/bin/env sh
# Build only the executable consumed by check_concat_csv_parity.py.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests
"$MOJO" build -I src tests/concat_csv_probe.mojo \
    -o target/tests/concat_csv_probe
printf 'Erzeugt: %s\n' "$ROOT/target/tests/concat_csv_probe"
