#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec "$ROOT/scripts/test_stage12c5fu.sh" "$@"

# previous stage: scripts/test_stage12c5ft.sh test_stage12c5fs.sh test_stage12c5fr.sh test_stage12c5fq.sh
