#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bn extends test_stage12c5bm.sh;
# its chain includes test_stage12c5bl.sh, test_stage12c5bk.sh and all earlier
# gates. It owns the combined classic/property/catalog order around corrected
# multi-domain true-fraction multiple plans.
exec scripts/test_stage12c5bn.sh "$@"
