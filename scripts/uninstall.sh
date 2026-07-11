#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
. "$ROOT/scripts/reta_manpages.sh"
reta_install_set_defaults

stage_path() {
    printf '%s%s\n' "$DESTDIR" "$1"
}

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBDIR=$(stage_path "$LIBDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")
STAGE_REFERENCEDIR=$(stage_path "$REFERENCEDIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

remove_public_command() {
    name=$1
    rm -f "$STAGE_BINDIR/$name" "$STAGE_BINDIR/$name.reta-source-id"
}

remove_library() {
    name=$1
    rm -f "$STAGE_LIBDIR/$name" "$STAGE_LIBDIR/$name.reta-source-id"
    rm -f "$STAGE_LIBEXECDIR/$name" "$STAGE_LIBEXECDIR/$name.reta-source-id"
    rm -f "$STAGE_LIBEXECDIR/mojo/$name"
}

# Remove the current public command set.
for name in $(reta_artifact_public_install_executables); do
    remove_public_command "$name"
done

# Also remove commands from older broad installs so narrowing the install set is
# fixed by a simple uninstall/install cycle.
for name in $(reta_artifact_legacy_installed_executables 2>/dev/null || true); do
    remove_public_command "$name"
done
for wrapper_name in $(reta_artifact_public_shell_wrappers 2>/dev/null || true); do
    remove_public_command "$wrapper_name"
done
remove_public_command mojo-runtime-exec
remove_public_command generate-html-native

for library_name in \
    $(reta_artifact_core_shared_libraries) \
    $(reta_artifact_prompt_shared_libraries) \
    $(reta_artifact_diagnostics_shared_libraries) \
    libKGENCompilerRTShared.so \
    libAsyncRTMojoBindings.so \
    libMSupportGlobals.so \
    libAsyncRTRuntimeGlobals.so \
    libNVPTX.so
 do
    remove_library "$library_name"
 done

for manpage in $(reta_public_manpages); do
    rm -f "$STAGE_MANDIR/man1/$manpage"
done
# Remove legacy broad-install manpages too when present.
for manpage in \
    generate-html-native.1 generate-readme-native.1 generate4readme.1 \
    grundStrukHtml-native.1 mojo-runtime-exec.1 \
    reta-extract-html-classes.1 reta-extract-html-classes-native.1 \
    reta-mojo.1 reta-mojo-activation.1 reta-mojo-architecture.1 \
    reta-mojo-architecture-probe.1 reta-mojo-boundaries.1 reta-mojo-coherence.1 \
    reta-mojo-combi-join.1 reta-mojo-compat.1 reta-mojo-compat-bin.1 \
    reta-mojo-contracts.1 reta-mojo-diagnostics.1 reta-mojo-domain-probe.1 \
    reta-mojo-execution-network.1 reta-mojo-exports.1 reta-mojo-facade.1 \
    reta-mojo-i18n.1 reta-mojo-impact.1 reta-mojo-migration.1 \
    reta-mojo-native.1 reta-mojo-package-integrity.1 \
    reta-mojo-parallel-execution.1 reta-mojo-persistence.1 reta-mojo-progress.1 \
    reta-mojo-rehearsal.1 reta-mojo-row-preparation.1 reta-mojo-schema.1 \
    reta-mojo-semantics.1 reta-mojo-sheaves.1 reta-mojo-table.1 \
    reta-mojo-tags.1 reta-mojo-traces.1 reta-mojo-validation.1 \
    reta-mojo-witnesses.1 reta-mojo-workflow.1 reta-native.1 \
    reta-prompt-complete.1 reta-prompt-native.1
 do
    rm -f "$STAGE_MANDIR/man1/$manpage"
 done

if [ "$STAGE_REFERENCEDIR" != "$STAGE_DATADIR/python_reference" ]; then
    rm -rf "$STAGE_REFERENCEDIR"
fi
rm -rf "$STAGE_LIBEXECDIR" "$STAGE_DATADIR"

maybe_ldconfig() {
    [ -z "$DESTDIR" ] || return 0
    case "$LIBDIR" in
        /usr/local/lib|/usr/lib|/lib|/lib64|/usr/lib64) ;;
        *) return 0 ;;
    esac
    command -v ldconfig >/dev/null 2>&1 || return 0
    ldconfig 2>/dev/null || true
}
maybe_ldconfig

printf 'Reta entfernt aus %s, %s und %s. Öffentliche Befehle wurden aus %s entfernt. Shared Libraries wurden aus %s entfernt.\n' \
    "$LIBEXECDIR" "$DATADIR" "$REFERENCEDIR" "$BINDIR" "$LIBDIR"
