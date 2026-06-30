#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

python3 tools/generate_architecture_map.py \
  --reference-root python_reference \
  --output "$TMP_DIR/architecture_map.mojo"
python3 tools/generate_architecture_boundaries.py \
  --reference-root python_reference \
  --output "$TMP_DIR/architecture_boundaries.mojo"
python3 tools/generate_architecture_contracts.py \
  --reference-root python_reference \
  --output "$TMP_DIR/architecture_contracts.mojo"
python3 tools/generate_architecture_witnesses.py \
  --reference-root python_reference \
  --output "$TMP_DIR/architecture_witnesses.mojo"

cmp src/reta_mojo/architecture_map.mojo "$TMP_DIR/architecture_map.mojo"
cmp src/reta_mojo/architecture_boundaries.mojo "$TMP_DIR/architecture_boundaries.mojo"
cmp src/reta_mojo/architecture_contracts.mojo "$TMP_DIR/architecture_contracts.mojo"
cmp src/reta_mojo/architecture_witnesses.mojo "$TMP_DIR/architecture_witnesses.mojo"
printf '%s\n' 'architecture-control generation: 4/4 byte-identical'
