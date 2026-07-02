#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=${RETA_REFERENCE_PYTHON:-"$(scripts/select_reference_python.sh)"}
mkdir -p target/tests

TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-semantics-builder.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
cp src/reta_mojo/semantics_builder_catalog.mojo "$TMP/catalog.expected.mojo"
cp assets/parameter_semantics_reference.json "$TMP/reference.expected.json"
PYTHONDONTWRITEBYTECODE=1 PYTHONHASHSEED=0 \
    "$PYTHON" tools/generate_semantics_builder_catalog.py >/dev/null
cmp "$TMP/catalog.expected.mojo" src/reta_mojo/semantics_builder_catalog.mojo
cmp "$TMP/reference.expected.json" assets/parameter_semantics_reference.json
cp src/reta_mojo/semantics_builder_catalog.mojo "$TMP/catalog.seed0.mojo"
cp assets/parameter_semantics_reference.json "$TMP/reference.seed0.json"
PYTHONDONTWRITEBYTECODE=1 PYTHONHASHSEED=1 \
    "$PYTHON" tools/generate_semantics_builder_catalog.py >/dev/null
cmp "$TMP/catalog.seed0.mojo" src/reta_mojo/semantics_builder_catalog.mojo
cmp "$TMP/reference.seed0.json" assets/parameter_semantics_reference.json

"$MOJO" build --no-optimization -I src tests/test_semantics_stage12c5f.mojo \
    -o target/tests/test_semantics_stage12c5f
./target/tests/test_semantics_stage12c5f

# Keep the generated full-catalog compile last. Mojo 1.0.0b2 can retain enough
# allocator pressure after this heavy compile to stall a following build in the
# same gate, although the following source compiles normally in a fresh process.
"$MOJO" build --no-optimization -I src tests/semantics_builder_probe.mojo \
    -o target/tests/semantics_builder_probe
PYTHONDONTWRITEBYTECODE=1 "$PYTHON" scripts/check_semantics_builder_parity.py
