#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bp extends test_stage12c5bo.sh
# and restores the complete multiple scope of compact and long-form fraction
# expressions before reciprocal-collision planning.  Historical source audits
# follow this transitive chain: test_stage12c5bn.sh -> test_stage12c5bm.sh ->
# test_stage12c5bl.sh -> test_stage12c5bk.sh.
exec scripts/test_stage12c5bp.sh "$@"
