#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
if [ "${1:-}" = "--" ]; then
    shift
fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5bp.sh" -- "$@"
fi

if [ -d "$ROOT/.git" ] && git ls-files --error-unmatch     tests/test_prompt_runtime.mojo.tmp >/dev/null 2>&1; then
    printf '%s\n'         'Veralteter Git-Indexeintrag: tests/test_prompt_runtime.mojo.tmp'         'Einmal ausführen: git rm --cached --ignore-unmatch tests/test_prompt_runtime.mojo.tmp'         'Danach die Datei löschen oder einen frischen 12c5bq-Arbeitsbaum verwenden.' >&2
    exit 1
fi

printf '\n== component-local compact v and position-independent global v ==\n'
"$ROOT/scripts/check_prompt_true_fraction_multiples.sh" -- "$@"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5bq_source.py \
    tests/test_python_fraction_multiple_scope_reference.py \
    tests/test_prompt_fraction_multiple_scope_source.py \
    tests/test_prompt_reciprocal_collision_source.py \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_stage12c5bp_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bq component-local compact-v and position-independent global-v contract complete'
