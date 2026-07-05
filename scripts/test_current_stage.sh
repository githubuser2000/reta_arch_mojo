#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bl extends test_stage12c5bk.sh
# and owns the previously atomic composition of classic integer-table families
# with explicit ordinary axes beside several corrected physical n/m domains.
exec scripts/test_stage12c5bl.sh "$@"
