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

require_file "$ROOT/python_reference/csv/religion.csv"
require_file "$ROOT/assets/parameter_aliases.tsv"
for manpage in $(reta_public_manpages); do
    require_file "$ROOT/man/$manpage"
done
require_file "$(reta_artifact_install_target_file "$ROOT")"

CORE_LIBRARY="$TARGETLIBDIR/$(reta_artifact_core_shared_libraries | sed -n '1p')"
PROMPT_LIBRARY="$TARGETLIBDIR/$(reta_artifact_prompt_shared_libraries | sed -n '1p')"
PROMPT_INTERACTIVE_LIBRARY="$TARGETLIBDIR/$(reta_artifact_prompt_shared_libraries | sed -n '2p')"

# Standard installation exposes only the public user commands.  The generated
# HTML command is installed under its public name generate_html, but its build
# artifact is still target/bin/generate-html-native.
for required_target in \
    reta \
    grundStrukHtml \
    rp \
    rpl \
    rpe \
    rpb \
    generate-html-native
 do
    maybe_require_stamp "$TARGETDIR/$required_target"
done
maybe_require_stamp "$CORE_LIBRARY"
maybe_require_stamp "$PROMPT_LIBRARY"
maybe_require_stamp "$PROMPT_INTERACTIVE_LIBRARY"

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBDIR=$(stage_path "$LIBDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")
STAGE_REFERENCEDIR=$(stage_path "$REFERENCEDIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

install -d "$STAGE_BINDIR" "$STAGE_LIBDIR" \
    "$STAGE_DATADIR/csv" "$STAGE_DATADIR/assets" \
    "$STAGE_MANDIR/man1"

# Remove old public diagnostics/stage helpers from previous broader installs.
for legacy in $(reta_artifact_legacy_installed_executables 2>/dev/null || true); do
    rm -f "$STAGE_BINDIR/$legacy" "$STAGE_BINDIR/$legacy.reta-source-id"
done
for wrapper_name in $(reta_artifact_public_shell_wrappers 2>/dev/null || true); do
    rm -f "$STAGE_BINDIR/$wrapper_name" "$STAGE_BINDIR/$wrapper_name.reta-source-id"
done
rm -f "$STAGE_BINDIR/mojo-runtime-exec" "$STAGE_BINDIR/mojo-runtime-exec.reta-source-id"

for manpage in $(reta_public_manpages); do
    install -m 0644 "$ROOT/man/$manpage" "$STAGE_MANDIR/man1/$manpage"
done

# Architecture-independent immutable data belongs below share/reta.
cp -aL "$ROOT/python_reference/csv/." "$STAGE_DATADIR/csv/"
cp -aL "$ROOT/assets/." "$STAGE_DATADIR/assets/"

# Keep the Python reference tree out of lib/reta. It is architecture-independent
# reference/compatibility material, so its installed home is share/reta.  Do not
# replace subtrees by symlinks: installed layout should not grow launcher/data
# symlink depots either.
rm -rf "$STAGE_LIBEXECDIR/python_reference" "$STAGE_REFERENCEDIR"
cp -aL "$ROOT/python_reference" "$STAGE_REFERENCEDIR"
find "$STAGE_REFERENCEDIR" -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true
find "$STAGE_REFERENCEDIR" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null || true

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

install_compiled_command reta reta
install_compiled_command grundStrukHtml grundStrukHtml
install_compiled_command rp rp
install_compiled_command rpl rpl
install_compiled_command rpe rpe
install_compiled_command rpb rpb
install_compiled_command generate_html generate-html-native

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

for library_name in $(reta_artifact_core_shared_libraries); do
    install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_core_shared.sh
done
for library_name in $(reta_artifact_prompt_shared_libraries); do
    install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_prompt_shared.sh
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
    $(reta_artifact_core_shared_libraries) \
    $(reta_artifact_prompt_shared_libraries) \
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
for forbidden in $(reta_artifact_legacy_installed_executables 2>/dev/null || true); do
    case "$forbidden" in
        reta|grundStrukHtml|rp|rpl|rpe|rpb|generate_html) continue ;;
    esac
    [ ! -e "$STAGE_BINDIR/$forbidden" ] || {
        printf 'Fehler: Diagnose-/Backend-Befehl darf nicht installiert werden: %s\n' "$STAGE_BINDIR/$forbidden" >&2
        exit 3
    }
done

cat > "$STAGE_DATADIR/INSTALL_LAYOUT" <<LAYOUT
prefix=$PREFIX
bindir=$BINDIR
binarydir=$BINDIR
libdir=$LIBDIR
legacy_libexecdir=$LIBEXECDIR
sharedlibdir=$LIBDIR
datadir=$DATADIR
csvdir=$DATADIR/csv
assetdir=$DATADIR/assets
referencedir=$REFERENCEDIR
mandir=$MANDIR
installed_public_commands=reta,rp,rpl,rpe,rpb,generate_html,grundStrukHtml
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

printf 'Reta installiert:\n'
printf '  Programme/Binaries: %s/{reta,rp,rpl,rpe,rpb,generate_html,grundStrukHtml}\n' "$BINDIR"
printf '  Shared Libraries:   %s\n' "$LIBDIR"
printf '  Compilerziele:      %s\n' "$INSTALLED_TARGETS"
printf '  Shared Libraries:   %s\n' "$INSTALLED_LIBRARIES"
printf '  CSV-Daten:          %s\n' "$DATADIR/csv"
printf '  Assets:             %s\n' "$DATADIR/assets"
printf '  Python-Referenz:    %s\n' "$REFERENCEDIR"
printf '  Manpages:           %s/man1/{generate_html,grundStrukHtml,reta,rp,rpl,rpe,rpb}.1\n' "$MANDIR"
if [ -n "$DESTDIR" ]; then
    printf '  Paketwurzel:        %s\n' "$DESTDIR"
fi
