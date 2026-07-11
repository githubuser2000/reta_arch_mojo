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
    rm -f "$STAGE_BINDIR/$name"
}

remove_library() {
    name=$1
    rm -f "$STAGE_LIBDIR/$name" "$STAGE_LIBDIR/$name.reta-source-id"
    rm -f "$STAGE_LIBEXECDIR/$name" "$STAGE_LIBEXECDIR/$name.reta-source-id"
}

while IFS= read -r name || [ -n "$name" ]; do
    case "$name" in
        ''|'#'*) continue ;;
    esac
    remove_public_command "$name"
done < "$ROOT/scripts/install_targets.txt"

for wrapper_name in $(reta_artifact_public_shell_wrappers); do
    remove_public_command "$wrapper_name"
done
remove_public_command mojo-runtime-exec

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
    rm -f "$STAGE_LIBEXECDIR/mojo/$library_name"
done

for manpage in $(reta_public_manpages); do
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
