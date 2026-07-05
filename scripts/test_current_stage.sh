#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bh extends test_stage12c5bg.sh,
# preserves the complete historical chain test_stage12c5bg.sh ->
# test_stage12c5bf.sh -> test_stage12c5be.sh -> test_stage12c5bd.sh -> …,
# migrates the two known stale
# command-parity assets, separates full-suite compilation from execution, and
# owns comma-local zero/exclusion axes beside corrected true fractions.
exec scripts/test_stage12c5bh.sh "$@"
