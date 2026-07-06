#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# previous current stage: test_stage12c5eb.sh
# previous previous current stage: test_stage12c5ea.sh
exec "$ROOT/scripts/test_stage12c5ec.sh" "$@"
