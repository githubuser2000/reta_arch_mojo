#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Advance only this one line for each stage.
exec scripts/test_stage12c5aw.sh "$@"
