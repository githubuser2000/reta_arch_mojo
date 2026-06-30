#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
UNIT=${PROMPT_PROPERTY_UNIT:-"$ROOT/target/tests/test_prompt_property_execution"}
INTEGRATION=${PROMPT_PROPERTY_INTEGRATION:-"$ROOT/target/tests/test_prompt_property_table_integration"}
mkdir -p "$ROOT/target/tests"
if [[ ! -x "$UNIT" ]]; then
    "$MOJO" build -I src tests/test_prompt_property_execution.mojo -o "$UNIT"
fi
if [[ ! -x "$INTEGRATION" ]]; then
    "$MOJO" build -I src tests/test_prompt_property_table_integration.mojo -o "$INTEGRATION"
fi
"$UNIT"
"$INTEGRATION"
