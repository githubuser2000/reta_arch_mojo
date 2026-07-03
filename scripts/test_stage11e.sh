#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
"$ROOT/scripts/require_built_targets.sh" scripts/build-heavy.sh \
    reta-mojo-rehearsal reta-mojo-activation

"$ROOT/bin/mojo-real" build -I src tests/test_architecture_rehearsal.mojo -o "$TEST_DIR/test-architecture-rehearsal"
"$TEST_DIR/test-architecture-rehearsal"
"$ROOT/bin/mojo-real" build -I src tests/test_architecture_activation.mojo -o "$TEST_DIR/test-architecture-activation"
"$TEST_DIR/test-architecture-activation"
./scripts/check_architecture_rehearsal_activation_parity.sh
./scripts/check_architecture_rehearsal_activation_generation.sh
printf '%s\n' 'stage11e focused tests: 30/30 plus 11/11 query parity plus 2/2 generated snapshots'
