#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# previous current stage: test_stage12c5ej.sh
# previous previous current stage: test_stage12c5ei.sh
# previous previous previous current stage: test_stage12c5eh.sh
# previous previous previous previous current stage: test_stage12c5eg.sh
# previous previous previous previous previous current stage: test_stage12c5ef.sh
# previous previous previous previous previous previous current stage: test_stage12c5ee.sh
exec "$ROOT/scripts/test_stage12c5ek.sh" "$@"
