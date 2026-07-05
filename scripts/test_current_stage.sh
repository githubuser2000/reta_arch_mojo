#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bq extends test_stage12c5bp.sh
# and separates component-local compact v prefixes from the standalone,
# position-independent global v/vielfache command.  Historical source audits
# follow the transitive chain test_stage12c5bo.sh -> test_stage12c5bn.sh ->
# test_stage12c5bm.sh -> test_stage12c5bl.sh -> test_stage12c5bk.sh.
exec scripts/test_stage12c5bq.sh "$@"
