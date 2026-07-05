#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bk extends test_stage12c5bj.sh,
# keeps command-parity resources hermetic even under an installed RETA_* shell,
# restores the outer row-1 sentinel for true-fraction divider axes, and separates
# explicit integer syntax from whole rows projected out of corrected n/m grids.
exec scripts/test_stage12c5bk.sh "$@"
