#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
"$ROOT/scripts/require_built_targets.sh" scripts/build-heavy.sh \
    reta-mojo-impact reta-mojo-migration

"$ROOT/bin/mojo-real" build -I src tests/test_architecture_impact.mojo -o "$TEST_DIR/test-architecture-impact"
"$TEST_DIR/test-architecture-impact"
"$ROOT/bin/mojo-real" build -I src tests/test_architecture_migration.mojo -o "$TEST_DIR/test-architecture-migration"
"$TEST_DIR/test-architecture-migration"
./scripts/test_stage11d_parity.sh
./scripts/check_architecture_impact_migration_generation.sh
printf '%s\n' 'stage11d focused tests: 24/24 plus 8/8 query parity plus 2/2 generated snapshots'
