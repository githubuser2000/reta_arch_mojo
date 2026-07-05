#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bo extends test_stage12c5bn.sh
# and fixes the case-sensitive native-probe assertion for the canonical
# --grundstrukturen=emotion option.
exec scripts/test_stage12c5bo.sh "$@"
