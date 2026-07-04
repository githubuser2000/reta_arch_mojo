#!/usr/bin/env sh
# Build and verify first; commit only a state that passed every requested check.
set -eu
#ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
#cd "$ROOT"
COMMIT_MESSAGE=${1:-12c5af}

scripts/build-all.sh
scripts/build-and-test-shared-diagnostics.sh
scripts/test_all.sh

git add -A
git commit -m "$COMMIT_MESSAGE"
