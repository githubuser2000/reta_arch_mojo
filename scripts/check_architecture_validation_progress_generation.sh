#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

python3 -B tools/generate_architecture_validation.py \
  --reference-root python_reference \
  --output "$TMP_DIR/architecture_validation.mojo"
python3 -B tools/generate_architecture_progress.py \
  --reference-root python_reference \
  --output "$TMP_DIR/architecture_progress.mojo"

cmp src/reta_mojo/architecture_validation.mojo "$TMP_DIR/architecture_validation.mojo"
cmp src/reta_mojo/architecture_progress.mojo "$TMP_DIR/architecture_progress.mojo"
printf '%s\n' 'architecture validation/progress generation: 2/2 byte-identical'
