#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
. "$ROOT/scripts/reta_manpages.sh"
reta_install_set_defaults
INSTALL_MOJO_RUNTIME=${RETA_INSTALL_MOJO_RUNTIME:-1}
TARGETDIR=${RETA_TARGET_DIR:-$ROOT/target/bin}
TARGETROOT=$(dirname -- "$TARGETDIR")
TARGETLIBDIR=${RETA_TARGET_LIB_DIR:-$TARGETROOT/lib/reta}
INSTALL_PROFILE=${RETA_INSTALL_PROFILE:-standard}

usage() {
    cat <<'USAGE'
Verwendung: scripts/install.sh [--standard|--zusatz|--all|--reference]

Installationsprofile:
  --standard   Nur öffentliche Nutzerbefehle: reta, rp, rpl, rpe, rpb,
               generate_html, grundStrukHtml. Dies ist der Default.
  --zusatz     Standard + reguläre Entwickler-/Diagnosebefehle.
  --all        Standard + Zusatz + schwere Architektur-/Stage-Diagnosen.
  --reference  Nur den alten Python-Referenzbaum als explizites Debug-/
               Paritätsmaterial unter share/reta/python_reference installieren.

standard, zusatz und all installieren python_reference bewusst nicht. Wer die
Python-Referenz zusätzlich will, führt --reference nach dem gewünschten
Nativprofil aus.

PREFIX, DESTDIR, BINDIR, LIBDIR, DATADIR, REFERENCEDIR und MANDIR können wie
bisher per Umgebung gesetzt werden.
USAGE
}

case ${1:-} in
    --standard) INSTALL_PROFILE=standard; shift ;;
    --zusatz|--diagnostics) INSTALL_PROFILE=zusatz; shift ;;
    --all|--alles) INSTALL_PROFILE=all; shift ;;
    --reference|--python-reference) INSTALL_PROFILE=reference; shift ;;
    -h|--help) usage; exit 0 ;;
esac
[ "$#" -eq 0 ] || { usage >&2; exit 2; }
reta_artifact_validate_install_profile "$INSTALL_PROFILE"

stage_path() {
    printf '%s%s\n' "$DESTDIR" "$1"
}

require_file() {
    [ -f "$1" ] || {
        printf 'Fehlende Installationsquelle: %s\n' "$1" >&2
        exit 2
    }
}

maybe_require_stamp() {
    require_file "$1"
    require_file "$1.reta-source-id"
}

word_in_list() {
    needle=$1
    shift
    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}

require_file "$ROOT/python_reference/csv/religion.csv"
require_file "$ROOT/assets/parameter_aliases.tsv"
for manpage in $(reta_profile_manpages "$INSTALL_PROFILE"); do
    require_file "$ROOT/man/$manpage"
done
require_file "$(reta_artifact_install_target_file "$ROOT")"

for pair in $(reta_artifact_profile_install_pairs "$INSTALL_PROFILE"); do
    source_name=${pair#*:}
    maybe_require_stamp "$TARGETDIR/$source_name"
done
for pair in $(reta_artifact_profile_script_pairs "$INSTALL_PROFILE"); do
    source_path=${pair#*:}
    require_file "$ROOT/$source_path"
done
for library_name in $(reta_artifact_profile_shared_libraries "$INSTALL_PROFILE"); do
    maybe_require_stamp "$TARGETLIBDIR/$library_name"
done

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBDIR=$(stage_path "$LIBDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")
STAGE_REFERENCEDIR=$(stage_path "$REFERENCEDIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

install_reference_tree() {
    install -d "$STAGE_DATADIR"
    rm -rf "$STAGE_LIBEXECDIR/python_reference" "$STAGE_REFERENCEDIR"
    install -d "$(dirname -- "$STAGE_REFERENCEDIR")"
    cp -aL "$ROOT/python_reference" "$STAGE_REFERENCEDIR"
    find "$STAGE_REFERENCEDIR" -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true
    find "$STAGE_REFERENCEDIR" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null || true
    # The reference tree is installed as data, not as another command depot.
    find "$STAGE_REFERENCEDIR" -type f -perm /111 -exec chmod a-x {} + 2>/dev/null || true
    if find "$STAGE_REFERENCEDIR" -type l 2>/dev/null | grep -q .; then
        printf '%s\n' 'Fehler: Python-Referenz darf keine Symlinks installieren.' >&2
        exit 3
    fi
    cat > "$STAGE_DATADIR/PYTHON_REFERENCE_LAYOUT" <<LAYOUT
prefix=$PREFIX
install_profile=reference
datadir=$DATADIR
referencedir=$REFERENCEDIR
python_reference_installed=1
LAYOUT
}

if [ "$INSTALL_PROFILE" = reference ]; then
    install_reference_tree
    printf 'Reta Python-Referenz installiert: %s\n' "$REFERENCEDIR"
    if [ -n "$DESTDIR" ]; then
        printf '  Paketwurzel:        %s\n' "$DESTDIR"
    fi
    exit 0
fi

install -d "$STAGE_BINDIR" "$STAGE_LIBDIR" \
    "$STAGE_DATADIR/csv" "$STAGE_DATADIR/assets" \
    "$STAGE_MANDIR/man1"

# Keep install profiles exact: installing --standard after --all removes the
# diagnostic commands and manpages again.  Libraries are filtered below too.
ALLOWED_COMMANDS=$(reta_artifact_profile_install_executables "$INSTALL_PROFILE" | tr '\n' ' ')
for command in $(reta_artifact_all_known_installed_executables 2>/dev/null || true); do
    case " $ALLOWED_COMMANDS " in
        *" $command "*) ;;
        *) rm -f "$STAGE_BINDIR/$command" "$STAGE_BINDIR/$command.reta-source-id" ;;
    esac
done

ALLOWED_MANPAGES=$(reta_profile_manpages "$INSTALL_PROFILE" | tr '\n' ' ')
for manpage in $(reta_all_manpages); do
    case " $ALLOWED_MANPAGES " in
        *" $manpage "*) ;;
        *) rm -f "$STAGE_MANDIR/man1/$manpage" ;;
    esac
done
for manpage in $(reta_profile_manpages "$INSTALL_PROFILE"); do
    install -m 0644 "$ROOT/man/$manpage" "$STAGE_MANDIR/man1/$manpage"
done

# Architecture-independent immutable data belongs below share/reta.
cp -aL "$ROOT/python_reference/csv/." "$STAGE_DATADIR/csv/"
cp -aL "$ROOT/assets/." "$STAGE_DATADIR/assets/"

# The old Python reference tree is not runtime material for native installs.
# Keep standard/zusatz/all exact and remove leftovers from older installs; use
# scripts/install.sh --reference for explicit parity/debug reference material.
rm -rf "$STAGE_LIBEXECDIR/python_reference" "$STAGE_REFERENCEDIR"
rm -f "$STAGE_DATADIR/PYTHON_REFERENCE_LAYOUT"

# Legacy private install trees are no longer used.
rm -rf "$STAGE_LIBEXECDIR/assets" \
       "$STAGE_LIBEXECDIR/bin" \
       "$STAGE_LIBEXECDIR/scripts" \
       "$STAGE_LIBEXECDIR/target" \
       "$STAGE_LIBEXECDIR/mojo"

CURRENT_SOURCE_ID=$("$ROOT/scripts/current_source_id.sh")
INSTALLED_TARGETS=0

install_compiled_command() {
    public_name=$1
    source_name=$2
    executable="$TARGETDIR/$source_name"
    RETA_TARGET_DIR="$TARGETDIR" \
    RETA_TARGET_LIB_DIR="$TARGETLIBDIR" \
    RETA_REBUILD_COMMAND=scripts/build-all.sh \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$executable"
    install -m 0755 "$executable" "$STAGE_BINDIR/$public_name"
    INSTALLED_TARGETS=$((INSTALLED_TARGETS + 1))
}

install_script_command() {
    public_name=$1
    source_path=$2
    install -m 0755 "$ROOT/$source_path" "$STAGE_BINDIR/$public_name"
    INSTALLED_TARGETS=$((INSTALLED_TARGETS + 1))
}

for pair in $(reta_artifact_profile_install_pairs "$INSTALL_PROFILE"); do
    public_name=${pair%%:*}
    source_name=${pair#*:}
    install_compiled_command "$public_name" "$source_name"
done
for pair in $(reta_artifact_profile_script_pairs "$INSTALL_PROFILE"); do
    public_name=${pair%%:*}
    source_path=${pair#*:}
    install_script_command "$public_name" "$source_path"
done

INSTALLED_LIBRARIES=0
install_shared_library() {
    source_library=$1
    rebuild_command=$2
    installed_name=$(basename -- "$source_library")
    RETA_TARGET_DIR="$TARGETDIR" \
    RETA_TARGET_LIB_DIR="$TARGETLIBDIR" \
    RETA_REBUILD_COMMAND="$rebuild_command" \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$source_library"
    rm -f "$STAGE_LIBEXECDIR/$installed_name" "$STAGE_LIBEXECDIR/$installed_name.reta-source-id"
    install -m 0644 "$source_library" "$STAGE_LIBDIR/$installed_name"
    INSTALLED_LIBRARIES=$((INSTALLED_LIBRARIES + 1))
}

ALLOWED_LIBRARIES="$(reta_artifact_profile_shared_libraries "$INSTALL_PROFILE" | tr '\n' ' ')"
for library_name in $(reta_artifact_shared_libraries); do
    case " $ALLOWED_LIBRARIES " in
        *" $library_name "*) ;;
        *) rm -f "$STAGE_LIBDIR/$library_name" "$STAGE_LIBDIR/$library_name.reta-source-id" \
                "$STAGE_LIBEXECDIR/$library_name" "$STAGE_LIBEXECDIR/$library_name.reta-source-id" ;;
    esac
done

for library_name in $(reta_artifact_profile_shared_libraries "$INSTALL_PROFILE"); do
    case "$library_name" in
        libreta_core_mojo.so) install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_core_shared.sh ;;
        libreta_prompt_mojo.so|libreta_prompt_interactive_mojo.so) install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_prompt_shared.sh ;;
        libreta_diagnostics_mojo.so) install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_diagnostics_shared.sh ;;
        *) install_shared_library "$TARGETLIBDIR/$library_name" scripts/build-all.sh ;;
    esac
done

if [ "$INSTALL_MOJO_RUNTIME" != 0 ]; then
    RUNTIME_DIR=$("$ROOT/scripts/find_mojo_runtime.sh")
    for library in \
        libKGENCompilerRTShared.so \
        libAsyncRTMojoBindings.so \
        libMSupportGlobals.so \
        libAsyncRTRuntimeGlobals.so \
        libNVPTX.so
    do
        require_file "$RUNTIME_DIR/$library"
        rm -f "$STAGE_LIBEXECDIR/mojo/$library"
        install -m 0644 "$RUNTIME_DIR/$library" "$STAGE_LIBDIR/$library"
        INSTALLED_LIBRARIES=$((INSTALLED_LIBRARIES + 1))
    done
fi

# Make accidental source-id/python-reference/private-runtime leakage a hard installation error.
if find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \( -name '*.reta-source-id' -o -name '*.reta-test-source-id' \) 2>/dev/null | grep -q .; then
    printf '%s\n' 'Fehler: Source-ID-Sidecars dürfen nicht installiert werden.' >&2
    exit 3
fi
for library_name in \
    $(reta_artifact_shared_libraries) \
    libKGENCompilerRTShared.so \
    libAsyncRTMojoBindings.so \
    libMSupportGlobals.so \
    libAsyncRTRuntimeGlobals.so \
    libNVPTX.so
 do
    [ ! -e "$STAGE_LIBDIR/$library_name.reta-source-id" ] || {
        printf 'Fehler: Source-ID-Sidecar in LIBDIR installiert: %s\n' "$STAGE_LIBDIR/$library_name.reta-source-id" >&2
        exit 3
    }
    if [ -e "$STAGE_LIBDIR/$library_name" ] && [ -x "$STAGE_LIBDIR/$library_name" ]; then
        printf 'Fehler: Library darf nicht ausführbar installiert werden: %s\n' "$STAGE_LIBDIR/$library_name" >&2
        exit 3
    fi
 done
if [ -e "$STAGE_LIBEXECDIR/python_reference" ]; then
    printf '%s\n' 'Fehler: python_reference darf nicht unter lib/reta installiert werden.' >&2
    exit 3
fi
if [ -e "$STAGE_LIBEXECDIR/bin" ] || [ -e "$STAGE_LIBEXECDIR/scripts" ]; then
    printf '%s\n' 'Fehler: bin/ und scripts/ dürfen nicht unter lib/reta installiert werden.' >&2
    exit 3
fi
if find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" "$STAGE_DATADIR" -type l 2>/dev/null | grep -q .; then
    printf '%s\n' 'Fehler: Installation darf keine Launcher-/Daten-Symlinks erzeugen.' >&2
    exit 3
fi
for forbidden in $(reta_artifact_all_known_installed_executables 2>/dev/null || true); do
    case " $ALLOWED_COMMANDS " in
        *" $forbidden "*) continue ;;
    esac
    [ ! -e "$STAGE_BINDIR/$forbidden" ] || {
        printf 'Fehler: Befehl gehört nicht zum Installationsprofil %s: %s\n' "$INSTALL_PROFILE" "$STAGE_BINDIR/$forbidden" >&2
        exit 3
    }
done

INSTALLED_COMMANDS=$(reta_artifact_profile_install_executables "$INSTALL_PROFILE" | paste -sd, -)
INSTALLED_MANPAGES=$(reta_profile_manpages "$INSTALL_PROFILE" | paste -sd, -)
cat > "$STAGE_DATADIR/INSTALL_LAYOUT" <<LAYOUT
prefix=$PREFIX
install_profile=$INSTALL_PROFILE
bindir=$BINDIR
binarydir=$BINDIR
libdir=$LIBDIR
legacy_libexecdir=$LIBEXECDIR
sharedlibdir=$LIBDIR
datadir=$DATADIR
csvdir=$DATADIR/csv
assetdir=$DATADIR/assets
referencedir=$REFERENCEDIR
python_reference_installed=0
mandir=$MANDIR
installed_public_commands=reta,rp,rpl,rpe,rpb,generate_html,grundStrukHtml
installed_commands=$INSTALLED_COMMANDS
installed_manpages=$INSTALLED_MANPAGES
compiled_targets=$INSTALLED_TARGETS
compiled_shared_libraries=$INSTALLED_LIBRARIES
installed_source_id_sidecars=0
LAYOUT

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

printf 'Reta installiert (%s):\n' "$INSTALL_PROFILE"
printf '  Programme/Binaries: %s\n' "$BINDIR"
printf '  Shared Libraries:   %s\n' "$LIBDIR"
printf '  Compilerziele:      %s\n' "$INSTALLED_TARGETS"
printf '  Shared Libraries:   %s\n' "$INSTALLED_LIBRARIES"
printf '  CSV-Daten:          %s\n' "$DATADIR/csv"
printf '  Assets:             %s\n' "$DATADIR/assets"
printf '  Python-Referenz:    nicht installiert; optional mit --reference: %s\n' "$REFERENCEDIR"
printf '  Manpages:           %s/man1\n' "$MANDIR"
if [ -n "$DESTDIR" ]; then
    printf '  Paketwurzel:        %s\n' "$DESTDIR"
fi
