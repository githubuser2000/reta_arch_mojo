#!/usr/bin/env sh
# Central build/install artifact manifest for reta_arch_mojo.
#
# Keep names here shell-parseable and newline-free.  Scripts may source this
# file to avoid diverging executable/shared-library lists across shell, Pixi
# and CMake entrypoints.

reta_artifact_core_starters() {
    printf '%s\n' 'reta grundStrukHtml'
}

reta_artifact_prompt_starters() {
    printf '%s\n' 'rp rpl rpe rpb'
}

reta_artifact_regular_executables() {
    printf '%s\n' 'reta-mojo-native reta-mojo-table reta-mojo-tags reta-mojo-i18n reta-mojo-package-integrity reta-mojo-exports reta-mojo-facade reta-mojo-workflow reta-mojo-sheaves reta-mojo-diagnostics reta-mojo-domain-probe reta-mojo-architecture-probe reta-mojo-combi-join reta-native reta-mojo-compat-bin reta-prompt-native reta-prompt-complete grundStrukHtml-native generate-html-native generate-readme-native reta-extract-html-classes-native'
}

reta_artifact_heavy_executables() {
    printf '%s\n' 'reta-mojo-semantics reta-mojo-schema reta-mojo-architecture reta-mojo-boundaries reta-mojo-contracts reta-mojo-witnesses reta-mojo-coherence reta-mojo-traces reta-mojo-impact reta-mojo-migration reta-mojo-rehearsal reta-mojo-activation reta-mojo-validation reta-mojo-progress reta-mojo-persistence reta-mojo-execution-network reta-mojo-parallel-execution reta-mojo-row-preparation'
}

reta_artifact_build_executables() {
    printf '%s %s %s\n' \
        "$(reta_artifact_core_starters)" \
        "$(reta_artifact_prompt_starters)" \
        "$(reta_artifact_regular_executables)"
}

reta_artifact_core_shared_libraries() {
    printf '%s\n' 'libreta-core.so'
}

reta_artifact_prompt_shared_libraries() {
    printf '%s\n' 'libreta-prompt.so libreta-prompt-interactive.so'
}

reta_artifact_diagnostics_shared_libraries() {
    printf '%s\n' 'libreta-mojo-diagnostics.so'
}

reta_artifact_shared_libraries() {
    printf '%s %s %s\n' \
        "$(reta_artifact_core_shared_libraries)" \
        "$(reta_artifact_prompt_shared_libraries)" \
        "$(reta_artifact_diagnostics_shared_libraries)"
}

reta_artifact_install_target_file() {
    root=${1:-.}
    printf '%s\n' "$root/scripts/install_targets.txt"
}
