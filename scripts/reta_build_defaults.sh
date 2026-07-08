#!/usr/bin/env sh
# Shared build/default values for shell, Pixi and script-backed CMake entrypoints.
# Keep this file dependency-light and POSIX-sh compatible; many scripts source it.

reta_build_set_defaults() {
    : "${RETA_MOJO_JOBS:=8}"
    : "${RETA_TEST_RUN_JOBS:=1}"
    : "${RETA_TEST_RUN_PARALLEL_JOBS:=4}"
    : "${RETA_TEST_RUN_TIMEOUT:=0}"
    : "${RETA_CMAKE_BUILD_DIR:=build}"
    : "${RETA_CMAKE_GENERATOR:=Ninja}"
    export RETA_MOJO_JOBS RETA_TEST_RUN_JOBS RETA_TEST_RUN_PARALLEL_JOBS \
        RETA_TEST_RUN_TIMEOUT RETA_CMAKE_BUILD_DIR RETA_CMAKE_GENERATOR
}

reta_require_positive_integer() {
    _reta_name=$1
    _reta_value=$2
    case $_reta_value in
        ''|*[!0-9]*)
            printf '%s muss eine positive Ganzzahl sein, erhalten: %s\n' \
                "$_reta_name" "$_reta_value" >&2
            return 2
            ;;
    esac
    if [ "$_reta_value" -lt 1 ]; then
        printf '%s muss mindestens 1 sein, erhalten: %s\n' \
            "$_reta_name" "$_reta_value" >&2
        return 2
    fi
}

reta_require_nonnegative_integer() {
    _reta_name=$1
    _reta_value=$2
    case $_reta_value in
        ''|*[!0-9]*)
            printf '%s muss eine nichtnegative Ganzzahl sein, erhalten: %s\n' \
                "$_reta_name" "$_reta_value" >&2
            return 2
            ;;
    esac
}

reta_build_validate_defaults() {
    reta_require_positive_integer RETA_MOJO_JOBS "$RETA_MOJO_JOBS"
    reta_require_positive_integer RETA_TEST_RUN_JOBS "$RETA_TEST_RUN_JOBS"
    reta_require_positive_integer RETA_TEST_RUN_PARALLEL_JOBS "$RETA_TEST_RUN_PARALLEL_JOBS"
    reta_require_nonnegative_integer RETA_TEST_RUN_TIMEOUT "$RETA_TEST_RUN_TIMEOUT"
}

reta_print_build_defaults() {
    reta_build_set_defaults
    reta_build_validate_defaults
    cat <<EOF_DEFAULTS
RETA_MOJO_JOBS=$RETA_MOJO_JOBS
RETA_TEST_RUN_JOBS=$RETA_TEST_RUN_JOBS
RETA_TEST_RUN_PARALLEL_JOBS=$RETA_TEST_RUN_PARALLEL_JOBS
RETA_TEST_RUN_TIMEOUT=$RETA_TEST_RUN_TIMEOUT
RETA_CMAKE_BUILD_DIR=$RETA_CMAKE_BUILD_DIR
RETA_CMAKE_GENERATOR=$RETA_CMAKE_GENERATOR
EOF_DEFAULTS
}
