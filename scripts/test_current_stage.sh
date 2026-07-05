#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bi extends test_stage12c5bh.sh,
# fixes the native prompt-history test's StringSlice/String ownership boundary,
# forwards optional Mojo compiler arguments through focused and full test builds,
# and owns standalone-negative no-op plus non-positive divider composition around
# corrected true-fraction CSV rectangles.
exec scripts/test_stage12c5bi.sh "$@"
