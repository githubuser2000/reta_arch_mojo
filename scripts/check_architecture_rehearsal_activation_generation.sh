#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
PYTHONDONTWRITEBYTECODE=1 python3 tools/generate_architecture_rehearsal.py \
  --reference-root python_reference \
  --output src/reta_mojo/architecture_rehearsal.mojo \
  --check
PYTHONDONTWRITEBYTECODE=1 python3 tools/generate_architecture_activation.py \
  --reference-root python_reference \
  --output src/reta_mojo/architecture_activation.mojo \
  --check
printf '%s\n' 'stage11e generation: 2/2 byte-identical'
