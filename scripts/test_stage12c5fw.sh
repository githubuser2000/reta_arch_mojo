#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5fv.sh" "$@"
fi

echo '== prompt shared build and install runtime smoke =='
"$ROOT/scripts/test_prompt_shared_runtime.sh" --dry-run
"$ROOT/scripts/build_prompt_shared.sh" --dry-run -- "$@"
"$ROOT/scripts/build_shared_library_targets.sh" --dry-run -- "$@"

if [ -x "$ROOT/target/bin/rpb" ] && \
   [ -f "$ROOT/target/lib/reta/libreta-prompt.so" ] && \
   [ -f "$ROOT/target/lib/reta/libreta-prompt-interactive.so" ]; then
    "$ROOT/scripts/test_prompt_shared_runtime.sh"
else
    printf '%s\n' 'Prompt-Shared-Runtime-Smoke übersprungen: bitte zuerst scripts/build-all.sh oder scripts/build_prompt_shared.sh ausführen.'
fi

python3 -m pytest \
    tests/test_stage12c5fw_source.py \
    tests/test_stage12c5fv_source.py \
    tests/test_prompt_shared_library_source.py \
    tests/test_stage12c5fu_source.py \
    tests/test_stage12c5ft_source.py \
    tests/test_source_archive_contract.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5fw prompt shared build and install smoke complete'
