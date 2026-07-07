#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5fx.sh" "$@"
fi

echo '== prompt shared missing library diagnostic fix =='
"$ROOT/scripts/test_prompt_shared_runtime.sh" --dry-run
"$ROOT/scripts/release_check.sh" --dry-run -- "$@"
python3 -m pytest \
    tests/test_stage12c5fy_source.py \
    tests/test_stage12c5fx_source.py \
    tests/test_stage12c5fw_source.py \
    tests/test_stage12c5fv_source.py \
    tests/test_prompt_shared_library_source.py \
    tests/test_source_archive_contract.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5fy prompt shared runtime missing-library diagnostic fix complete'
