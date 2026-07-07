#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5fw.sh" "$@"
fi

echo '== release check install layout gate =='
"$ROOT/scripts/release_check.sh" --dry-run -- "$@"
python3 -m pytest \
    tests/test_stage12c5fx_source.py \
    tests/test_stage12c5fw_source.py \
    tests/test_stage12c5fv_source.py \
    tests/test_prompt_shared_library_source.py \
    tests/test_stage12c5fu_source.py \
    tests/test_source_archive_contract.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5fx release check install layout gate complete'
