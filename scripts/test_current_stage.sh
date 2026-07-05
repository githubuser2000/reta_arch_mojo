#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bm extends test_stage12c5bl.sh;
# the historical chain still includes test_stage12c5bk.sh and all earlier gates.
# and owns EIGN/EIGR plus numeric 16/15 axes around corrected multi-domain
# true-fraction multiple plans.
exec scripts/test_stage12c5bm.sh "$@"
