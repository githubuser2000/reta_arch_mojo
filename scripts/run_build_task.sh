#!/usr/bin/env sh
set -eu

usage() {
    cat <<'USAGE'
Verwendung: scripts/run_build_task.sh [--dry-run] TASK [MOJO_BUILD_OPTION ...]

Zentraler Einstiegspunkt für Pixi- und CMake-Tasks.  Direkte Shell-Skripte
bleiben gültig; dieser Wrapper sorgt nur dafür, dass die bequemen Task-Varianten
alle dieselben Defaults verwenden.

Build-Defaults:
  RETA_MOJO_JOBS=8                 Default für mojo build, falls keine -j-Option übergeben wird
  RETA_TEST_RUN_JOBS=1             Default für sequentiellen Testlauf
  RETA_TEST_RUN_PARALLEL_JOBS=4    Default für *-parallel Tasks
  RETA_TEST_RUN_TIMEOUT=0          0 bedeutet kein Timeout
  RETA_DRY_RUN=1                   Befehle nur anzeigen, nicht ausführen

Tasks:
  build
  build-heavy
  build-all
  build-core-shared
  build-prompt-shared
  build-shared
  build-tests
  run-tests
  run-tests-parallel
  test
  test-parallel
  test-all
  release-check
  release-plan
USAGE
}

case ${1:-} in
    --dry-run)
        RETA_DRY_RUN=1
        export RETA_DRY_RUN
        shift
        ;;
esac

case ${1:-} in
    -h|--help|'')
        usage
        exit 0
        ;;
esac

TASK=$1
shift
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/reta_build_defaults.sh"
. "$ROOT/scripts/mojo_build_options.sh"
. "$ROOT/scripts/reta_command_runner.sh"
reta_build_set_defaults
reta_build_validate_defaults
mojo_validate_build_options "$@"

run_mojo_script() {
    _reta_script=$1
    shift
    if mojo_has_thread_option "$@"; then
        reta_run_or_print "$ROOT/$_reta_script" -- "$@"
    else
        reta_run_or_print "$ROOT/$_reta_script" -- -j "$RETA_MOJO_JOBS" "$@"
    fi
}

run_mojo_script_exec() {
    _reta_script=$1
    shift
    if mojo_has_thread_option "$@"; then
        reta_exec_or_print "$ROOT/$_reta_script" -- "$@"
    else
        reta_exec_or_print "$ROOT/$_reta_script" -- -j "$RETA_MOJO_JOBS" "$@"
    fi
}

case $TASK in
    build)
        run_mojo_script_exec scripts/build.sh "$@"
        ;;
    build-heavy)
        run_mojo_script_exec scripts/build-heavy.sh "$@"
        ;;
    build-all)
        run_mojo_script_exec scripts/build-all.sh "$@"
        ;;
    build-core-shared)
        run_mojo_script_exec scripts/build_core_shared.sh "$@"
        ;;
    build-prompt-shared)
        run_mojo_script_exec scripts/build_prompt_shared.sh "$@"
        ;;
    build-shared)
        run_mojo_script_exec scripts/build_shared_library_targets.sh "$@"
        ;;
    build-tests)
        run_mojo_script_exec scripts/build-tests.sh "$@"
        ;;
    run-tests)
        reta_exec_or_print "$ROOT/scripts/run-tests.sh" --jobs "$RETA_TEST_RUN_JOBS"
        ;;
    run-tests-parallel)
        reta_exec_or_print env RETA_TEST_RUN_JOBS="$RETA_TEST_RUN_PARALLEL_JOBS" \
            "$ROOT/scripts/run-tests.sh" --jobs "$RETA_TEST_RUN_PARALLEL_JOBS"
        ;;
    test)
        run_mojo_script scripts/build-tests.sh "$@"
        reta_exec_or_print "$ROOT/scripts/run-tests.sh" --jobs "$RETA_TEST_RUN_JOBS"
        ;;
    test-parallel)
        run_mojo_script scripts/build-tests.sh "$@"
        reta_exec_or_print env RETA_TEST_RUN_JOBS="$RETA_TEST_RUN_PARALLEL_JOBS" \
            "$ROOT/scripts/run-tests.sh" --jobs "$RETA_TEST_RUN_PARALLEL_JOBS"
        ;;
    test-all)
        if mojo_has_thread_option "$@"; then
            reta_exec_or_print "$ROOT/scripts/test_all.sh" --run-jobs "$RETA_TEST_RUN_JOBS" -- "$@"
        else
            reta_exec_or_print "$ROOT/scripts/test_all.sh" --run-jobs "$RETA_TEST_RUN_JOBS" -- -j "$RETA_MOJO_JOBS" "$@"
        fi
        ;;
    release-check)
        run_mojo_script_exec scripts/release_check.sh "$@"
        ;;
    release-plan)
        if mojo_has_thread_option "$@"; then
            reta_exec_or_print "$ROOT/scripts/release_check.sh" --dry-run -- "$@"
        else
            reta_exec_or_print "$ROOT/scripts/release_check.sh" --dry-run -- -j "$RETA_MOJO_JOBS" "$@"
        fi
        ;;
    *)
        printf 'Unbekannter Build-Task: %s\n' "$TASK" >&2
        usage >&2
        exit 2
        ;;
esac
