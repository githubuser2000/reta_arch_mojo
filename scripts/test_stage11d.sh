#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
BIN_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
mkdir -p "$TEST_DIR" "$BIN_DIR"

"$ROOT/bin/mojo-real" build -I src tests/test_architecture_impact.mojo -o "$TEST_DIR/test-architecture-impact"
"$TEST_DIR/test-architecture-impact"
"$ROOT/bin/mojo-real" build -I src tests/test_architecture_migration.mojo -o "$TEST_DIR/test-architecture-migration"
"$TEST_DIR/test-architecture-migration"
"$ROOT/bin/mojo-real" build -I src src/architecture_impact_main.mojo -o "$BIN_DIR/reta-mojo-impact"
"$ROOT/bin/mojo-real" build -I src src/architecture_migration_main.mojo -o "$BIN_DIR/reta-mojo-migration"

./scripts/test_stage11d_parity.sh
./scripts/check_architecture_impact_migration_generation.sh
printf '%s\n' 'stage11d focused tests: 24/24 plus 8/8 query parity plus 2/2 generated snapshots'
