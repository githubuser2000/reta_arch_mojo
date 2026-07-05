#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bf extends test_stage12c5be.sh,
# whose complete predecessor chain includes test_stage12c5bd.sh and all earlier
# runtime gates, then verifies domain-specific multi-fraction prompt plans.
exec scripts/test_stage12c5bf.sh "$@"
