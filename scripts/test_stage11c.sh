#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TARGET_DIR"

"$ROOT/bin/mojo-real" build -I src tests/test_architecture_coherence.mojo -o "$TARGET_DIR/test-architecture-coherence"
"$TARGET_DIR/test-architecture-coherence"
"$ROOT/bin/mojo-real" build -I src tests/test_architecture_traces.mojo -o "$TARGET_DIR/test-architecture-traces"
"$TARGET_DIR/test-architecture-traces"

./scripts/check_architecture_control_generation.sh
printf '%s\n' 'stage11c focused tests: 19/19 plus 6/6 generated snapshots'
