#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

build_and_run() {
    source=$1
    name=$(basename "$source" .mojo)
    "$MOJO" build -I src "$source" -o "target/tests/$name"
    "target/tests/$name"
}

build_and_run tests/test_table_rendering.mojo
build_and_run tests/test_html_cell_metadata.mojo
./scripts/check_html_heading_catalog.sh
./scripts/check_markup_parity.sh
printf '%s\n' 'Stage 9 Markup-Rendererprüfungen bestanden.'
