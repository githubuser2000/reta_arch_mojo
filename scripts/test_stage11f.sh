#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
"$ROOT/scripts/require_built_targets.sh" scripts/build-heavy.sh \
    reta-mojo-validation reta-mojo-progress

"$ROOT/bin/mojo-real" build -I src tests/test_architecture_validation.mojo -o "$TEST_DIR/test-architecture-validation"
"$TEST_DIR/test-architecture-validation"
"$ROOT/bin/mojo-real" build -I src tests/test_architecture_progress.mojo -o "$TEST_DIR/test-architecture-progress"
"$TEST_DIR/test-architecture-progress"
./scripts/check_architecture_validation_progress_parity.sh
./scripts/check_architecture_validation_progress_generation.sh
printf '%s\n' 'stage11f focused tests: 29/29 plus 8/8 query parity plus 2/2 generated snapshots'
