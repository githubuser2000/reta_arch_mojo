#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
. "$ROOT/scripts/reta_manpages.sh"
reta_install_set_defaults
UNINSTALL_PROFILE=${RETA_UNINSTALL_PROFILE:-all}

usage() {
    cat <<'USAGE'
Verwendung: scripts/uninstall.sh [--standard|--zusatz|--all]

Deinstallationsprofile:
  --standard   entfernt die Standardinstallation
  --zusatz     entfernt Standard + reguläre Entwickler-/Diagnosebefehle
  --all        entfernt alles, inklusive schwerer Architektur-/Stage-Diagnosen

Ohne Option ist --all der Default, damit alte breite Installationen sicher
aufgeräumt werden.
USAGE
}

case ${1:-} in
    --standard) UNINSTALL_PROFILE=standard; shift ;;
    --zusatz|--diagnostics) UNINSTALL_PROFILE=zusatz; shift ;;
    --all|--alles) UNINSTALL_PROFILE=all; shift ;;
    -h|--help) usage; exit 0 ;;
esac
[ "$#" -eq 0 ] || { usage >&2; exit 2; }
reta_artifact_validate_install_profile "$UNINSTALL_PROFILE"

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

for name in $(reta_artifact_profile_install_executables "$UNINSTALL_PROFILE"); do
    remove_public_command "$name"
done
if [ "$UNINSTALL_PROFILE" = all ]; then
    # Also remove commands from older broad installs so narrowing the install set
    # is fixed by a simple uninstall/install cycle.
    for name in $(reta_artifact_legacy_installed_executables 2>/dev/null || true); do
        remove_public_command "$name"
    done
fi

for library_name in \
    $(reta_artifact_profile_shared_libraries "$UNINSTALL_PROFILE") \
    libKGENCompilerRTShared.so \
    libAsyncRTMojoBindings.so \
    libMSupportGlobals.so \
    libAsyncRTRuntimeGlobals.so \
    libNVPTX.so
 do
    remove_library "$library_name"
 done

for manpage in $(reta_profile_manpages "$UNINSTALL_PROFILE"); do
    rm -f "$STAGE_MANDIR/man1/$manpage"
done
if [ "$UNINSTALL_PROFILE" = all ]; then
    for manpage in $(reta_all_manpages); do
        rm -f "$STAGE_MANDIR/man1/$manpage"
    done
fi

if [ "$UNINSTALL_PROFILE" = all ]; then
    if [ "$STAGE_REFERENCEDIR" != "$STAGE_DATADIR/python_reference" ]; then
        rm -rf "$STAGE_REFERENCEDIR"
    fi
    rm -rf "$STAGE_LIBEXECDIR" "$STAGE_DATADIR"
else
    # Data/reference files are shared by cumulative profiles. Keep them unless
    # the caller requests the full cleanup.
    rm -rf "$STAGE_LIBEXECDIR"
fi

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

printf 'Reta entfernt (%s): Befehle aus %s, Shared Libraries aus %s.\n' \
    "$UNINSTALL_PROFILE" "$BINDIR" "$LIBDIR"
