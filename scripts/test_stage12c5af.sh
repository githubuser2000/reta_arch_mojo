#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

"$ROOT/scripts/test_atomic_build.sh"
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_atomic_build_publication.py \
    tests/test_stage_build_separation.py \
    tests/test_stage12c5s_source.py \
    tests/test_diagnostics_shared_library_source.py \
    tests/test_install_layout.py \
    tests/test_install_target_manifest.py
