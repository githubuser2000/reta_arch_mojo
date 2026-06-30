#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
python3 tools/generate_architecture_impact.py --reference-root python_reference --output src/reta_mojo/architecture_impact.mojo --check
python3 tools/generate_architecture_migration.py --reference-root python_reference --output src/reta_mojo/architecture_migration.mojo --check
printf '%s\n' 'stage11d generation: 2/2 byte-identical'
