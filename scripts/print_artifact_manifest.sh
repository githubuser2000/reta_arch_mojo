#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_artifacts.sh"

print_words() {
    label=$1
    shift
    printf '%s=' "$label"
    first=1
    for item in "$@"; do
        if [ "$first" = 1 ]; then
            first=0
        else
            printf ','
        fi
        printf '%s' "$item"
    done
    printf '\n'
}

# shellcheck disable=SC2046
print_words core_starters $(reta_artifact_core_starters)
# shellcheck disable=SC2046
print_words prompt_starters $(reta_artifact_prompt_starters)
# shellcheck disable=SC2046
print_words regular_executables $(reta_artifact_regular_executables)
# shellcheck disable=SC2046
print_words heavy_executables $(reta_artifact_heavy_executables)
# shellcheck disable=SC2046
print_words build_executables $(reta_artifact_build_executables)
# shellcheck disable=SC2046
print_words shared_libraries $(reta_artifact_shared_libraries)
printf 'install_targets_file=%s\n' "$(reta_artifact_install_target_file "$ROOT")"
printf 'install_targets_count=%s\n' "$(grep -Ev '^[[:space:]]*($|#)' "$(reta_artifact_install_target_file "$ROOT")" | wc -l | tr -d ' ')"
