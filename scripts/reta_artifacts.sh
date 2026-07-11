#!/usr/bin/env sh
# Central build/install artifact manifest for reta_arch_mojo.
#
# Keep names here shell-parseable and newline-free. Scripts source this file to
# avoid diverging executable/shared-library lists across shell, Pixi and CMake
# entrypoints.  Each manifest function emits one artifact per line.

reta_artifact_core_starters() {
    cat <<'ARTIFACTS'
reta
grundStrukHtml
ARTIFACTS
}

reta_artifact_prompt_starters() {
    cat <<'ARTIFACTS'
rp
rpl
rpe
rpb
ARTIFACTS
}

reta_artifact_regular_executables() {
    cat <<'ARTIFACTS'
generate-html-native
generate-readme-native
reta-extract-html-classes-native
grundStrukHtml-native
reta-mojo-combi-join
reta-mojo-diagnostics
reta-mojo-architecture-probe
reta-mojo-domain-probe
reta-mojo-compat-bin
reta-mojo-exports
reta-mojo-facade
reta-mojo-sheaves
reta-mojo-workflow
reta-mojo-i18n
reta-mojo-native
reta-mojo-package-integrity
reta-mojo-table
reta-mojo-tags
reta-native
reta-prompt-complete
reta-prompt-native
ARTIFACTS
}

reta_artifact_heavy_executables() {
    cat <<'ARTIFACTS'
reta-mojo-activation
reta-mojo-architecture
reta-mojo-boundaries
reta-mojo-coherence
reta-mojo-contracts
reta-mojo-execution-network
reta-mojo-impact
reta-mojo-migration
reta-mojo-parallel-execution
reta-mojo-persistence
reta-mojo-progress
reta-mojo-rehearsal
reta-mojo-row-preparation
reta-mojo-schema
reta-mojo-semantics
reta-mojo-traces
reta-mojo-validation
reta-mojo-witnesses
ARTIFACTS
}

reta_artifact_build_executables() {
    reta_artifact_core_starters
    reta_artifact_prompt_starters
    reta_artifact_regular_executables
}

reta_artifact_standard_install_pairs() {
    cat <<'ARTIFACTS'
reta:reta
grundStrukHtml:grundStrukHtml
rp:rp
rpl:rpl
rpe:rpe
rpb:rpb
generate_html:generate-html-native
ARTIFACTS
}

reta_artifact_zusatz_alias_pairs() {
    cat <<'ARTIFACTS'
generate4readme:generate-readme-native
reta-extract-html-classes:reta-extract-html-classes-native
reta-mojo:reta-mojo-native
reta-mojo-compat:reta-mojo-compat-bin
ARTIFACTS
}

reta_artifact_regular_install_pairs() {
    for executable in $(reta_artifact_regular_executables); do
        printf '%s:%s\n' "$executable" "$executable"
    done
}

reta_artifact_heavy_install_pairs() {
    for executable in $(reta_artifact_heavy_executables); do
        printf '%s:%s\n' "$executable" "$executable"
    done
}

reta_artifact_zusatz_script_pairs() {
    cat <<'ARTIFACTS'
mojo-runtime-exec:tools/wrappers/mojo-runtime-exec
ARTIFACTS
}

reta_artifact_validate_install_profile() {
    case ${1:-standard} in
        standard|zusatz|all|reference) return 0 ;;
        *)
            printf 'Unbekanntes Installationsprofil: %s\n' "$1" >&2
            printf '%s\n' 'Erlaubt: standard, zusatz, all, reference' >&2
            return 2
            ;;
    esac
}

reta_artifact_profile_install_pairs() {
    profile=${1:-standard}
    reta_artifact_validate_install_profile "$profile" || return $?
    [ "$profile" = reference ] && return 0
    reta_artifact_standard_install_pairs
    case "$profile" in
        standard|reference) ;;
        zusatz)
            reta_artifact_zusatz_alias_pairs
            reta_artifact_regular_install_pairs
            ;;
        all)
            reta_artifact_zusatz_alias_pairs
            reta_artifact_regular_install_pairs
            reta_artifact_heavy_install_pairs
            ;;
    esac
}

reta_artifact_profile_script_pairs() {
    profile=${1:-standard}
    reta_artifact_validate_install_profile "$profile" || return $?
    case "$profile" in
        standard|reference) ;;
        zusatz|all) reta_artifact_zusatz_script_pairs ;;
    esac
}

reta_artifact_profile_install_executables() {
    profile=${1:-standard}
    reta_artifact_validate_install_profile "$profile" || return $?
    for pair in $(reta_artifact_profile_install_pairs "$profile"); do
        printf '%s\n' "${pair%%:*}"
    done
    for pair in $(reta_artifact_profile_script_pairs "$profile"); do
        printf '%s\n' "${pair%%:*}"
    done
}

reta_artifact_public_install_executables() {
    reta_artifact_profile_install_executables standard
}

reta_artifact_zusatz_install_executables() {
    reta_artifact_profile_install_executables zusatz
}

reta_artifact_all_install_executables() {
    reta_artifact_profile_install_executables all
}

# Backwards-compatible name: the default install target set is the standard
# public command profile.  scripts/install_targets.txt intentionally tracks only
# this default profile.
reta_artifact_install_executables() {
    reta_artifact_public_install_executables
}

reta_artifact_public_shell_wrappers() {
    # Standard installs do not expose shell wrapper helper commands.
    :
}

reta_artifact_all_known_installed_executables() {
    reta_artifact_all_install_executables
    reta_artifact_legacy_installed_executables
}

reta_artifact_legacy_installed_executables() {
    reta_artifact_regular_executables
    reta_artifact_heavy_executables
    cat <<'ARTIFACTS'
generate4readme
reta-extract-html-classes
reta-mojo
reta-mojo-compat
mojo-runtime-exec
generate-html-native
generate-readme-native
reta-extract-html-classes-native
grundStrukHtml-native
reta-native
reta-prompt-native
reta-prompt-complete
ARTIFACTS
}

reta_artifact_core_shared_libraries() {
    cat <<'ARTIFACTS'
libreta_core_mojo.so
ARTIFACTS
}

reta_artifact_prompt_shared_libraries() {
    cat <<'ARTIFACTS'
libreta_prompt_mojo.so
libreta_prompt_interactive_mojo.so
ARTIFACTS
}

reta_artifact_diagnostics_shared_libraries() {
    cat <<'ARTIFACTS'
libreta_diagnostics_mojo.so
ARTIFACTS
}

reta_artifact_profile_shared_libraries() {
    profile=${1:-standard}
    reta_artifact_validate_install_profile "$profile" || return $?
    [ "$profile" = reference ] && return 0
    reta_artifact_core_shared_libraries
    reta_artifact_prompt_shared_libraries
    case "$profile" in
        standard|reference) ;;
        zusatz|all) reta_artifact_diagnostics_shared_libraries ;;
    esac
}

reta_artifact_shared_libraries() {
    reta_artifact_core_shared_libraries
    reta_artifact_prompt_shared_libraries
    reta_artifact_diagnostics_shared_libraries
}

reta_artifact_install_target_file() {
    root=${1:-.}
    printf '%s\n' "$root/scripts/install_targets.txt"
}
