#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5ft.sh" "$@"
fi

echo '== prompt shared official build layout =='
"$ROOT/scripts/build_prompt_shared.sh" --dry-run -- "$@"
"$ROOT/scripts/build_shared_library_targets.sh" --dry-run -- "$@"

# The active build is intentionally left to scripts/build-all.sh on the user's
# machine; this stage proves the official layout, launcher routing and install
# contract source-side without starting Mojo compilation here.
python3 -m pytest \
    tests/test_stage12c5fu_source.py \
    tests/test_prompt_shared_library_source.py \
    tests/test_stage12c5ft_source.py \
    tests/test_stage12c5fs_source.py \
    tests/test_source_archive_contract.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5fu prompt shared official build layout complete'
