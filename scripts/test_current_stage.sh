#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bu extends 12c5bt with the
# position-independent compound `leeren` effect, native terminal-row geometry
# and the Equatable-only companion-effect regression fix.
# Historical transitive-chain anchors retained for source-audit continuity:
# test_stage12c5bk.sh -> test_stage12c5bl.sh -> test_stage12c5bm.sh ->
# test_stage12c5bn.sh -> test_stage12c5bo.sh -> test_stage12c5bp.sh ->
# test_stage12c5bq.sh -> test_stage12c5br.sh -> test_stage12c5bs.sh ->
# test_stage12c5bt.sh -> test_stage12c5bu.sh.
exec scripts/test_stage12c5bu.sh "$@"
