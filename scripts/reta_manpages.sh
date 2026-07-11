#!/usr/bin/env sh
# Central manual-page manifest for shell, Pixi and CMake install/check entrypoints.

reta_standard_manpages() {
    cat <<'MANPAGES'
generate_html.1
grundStrukHtml.1
reta.1
rp.1
rpb.1
rpe.1
rpl.1
MANPAGES
}

reta_zusatz_manpages() {
    reta_standard_manpages
    cat <<'MANPAGES'
generate-html-native.1
generate-readme-native.1
generate4readme.1
grundStrukHtml-native.1
mojo-runtime-exec.1
reta-extract-html-classes-native.1
reta-extract-html-classes.1
reta-mojo-architecture-probe.1
reta-mojo-combi-join.1
reta-mojo-compat-bin.1
reta-mojo-compat.1
reta-mojo-diagnostics.1
reta-mojo-domain-probe.1
reta-mojo-exports.1
reta-mojo-facade.1
reta-mojo-i18n.1
reta-mojo-native.1
reta-mojo-package-integrity.1
reta-mojo-sheaves.1
reta-mojo-table.1
reta-mojo-tags.1
reta-mojo-workflow.1
reta-mojo.1
reta-native.1
reta-prompt-complete.1
reta-prompt-native.1
MANPAGES
}

reta_all_manpages() {
    reta_zusatz_manpages
    cat <<'MANPAGES'
reta-mojo-activation.1
reta-mojo-architecture.1
reta-mojo-boundaries.1
reta-mojo-coherence.1
reta-mojo-contracts.1
reta-mojo-execution-network.1
reta-mojo-impact.1
reta-mojo-migration.1
reta-mojo-parallel-execution.1
reta-mojo-persistence.1
reta-mojo-progress.1
reta-mojo-rehearsal.1
reta-mojo-row-preparation.1
reta-mojo-schema.1
reta-mojo-semantics.1
reta-mojo-traces.1
reta-mojo-validation.1
reta-mojo-witnesses.1
MANPAGES
}

reta_profile_manpages() {
    profile=${1:-standard}
    case "$profile" in
        standard) reta_standard_manpages ;;
        zusatz) reta_zusatz_manpages ;;
        all) reta_all_manpages ;;
        reference) : ;;
        *)
            printf 'Unbekanntes Manpage-Profil: %s\n' "$profile" >&2
            return 2
            ;;
    esac
}

# Backwards-compatible name used by existing tests and standard installation.
reta_public_manpages() {
    reta_standard_manpages
}
