#!/usr/bin/env sh
set -eu

# Stable entry point used by do.sh. Stage 12c5bj extends test_stage12c5bi.sh
# and makes command-parity verification independent of the ambient CPython
# minor version. Stage tests validate pinned asset hashes without regenerating
# or mutating source fixtures; explicit --check-reference remains a maintainer
# diagnostic for interpreter-specific Python reference output.
exec scripts/test_stage12c5bj.sh "$@"
