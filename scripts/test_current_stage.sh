#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bg extends test_stage12c5bf.sh;
# its predecessor chain continues through test_stage12c5be.sh and
# test_stage12c5bd.sh to every earlier runtime gate. This stage repairs
# environment-independent command-parity assets and verifies the positive
# ordinary integer-axis composition beside true fraction multiples.
exec scripts/test_stage12c5bg.sh "$@"
