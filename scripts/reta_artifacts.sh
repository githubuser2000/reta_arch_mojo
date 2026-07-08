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

reta_artifact_install_executables() {
    reta_artifact_build_executables
    reta_artifact_heavy_executables
}

reta_artifact_core_shared_libraries() {
    cat <<'ARTIFACTS'
libreta-core.so
ARTIFACTS
}

reta_artifact_prompt_shared_libraries() {
    cat <<'ARTIFACTS'
libreta-prompt.so
libreta-prompt-interactive.so
ARTIFACTS
}

reta_artifact_diagnostics_shared_libraries() {
    cat <<'ARTIFACTS'
libreta-mojo-diagnostics.so
ARTIFACTS
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
