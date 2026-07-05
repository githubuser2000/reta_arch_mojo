#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5be extends the complete
# scripts/test_stage12c5bd.sh chain and then verifies the workflow repair.
exec scripts/test_stage12c5be.sh "$@"
