#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec "$ROOT/scripts/test_stage12c5fx.sh" "$@"

# previous stage: scripts/test_stage12c5fw.sh test_stage12c5fv.sh test_stage12c5fu.sh test_stage12c5ft.sh test_stage12c5fs.sh
