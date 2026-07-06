#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bx moves the remaining
# stored-output/addition decision into the typed prompt-interaction owner and
# documents the Python list/string TypeError on the historical addition path.
# Historical transitive-chain anchors retained for source-audit continuity:
# test_stage12c5bk.sh -> test_stage12c5bl.sh -> test_stage12c5bm.sh ->
# test_stage12c5bn.sh -> test_stage12c5bo.sh -> test_stage12c5bp.sh ->
# test_stage12c5bq.sh -> test_stage12c5br.sh -> test_stage12c5bs.sh ->
# test_stage12c5bt.sh -> test_stage12c5bu.sh -> test_stage12c5bv.sh ->
# test_stage12c5bw.sh -> test_stage12c5bx.sh.
exec scripts/test_stage12c5bx.sh "$@"
