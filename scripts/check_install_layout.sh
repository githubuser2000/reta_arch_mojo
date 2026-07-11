#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=${TMPDIR:-/tmp}/reta-install-layout.$$
STAGE=$TMP/stage
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
. "$ROOT/scripts/reta_manpages.sh"
reta_install_set_defaults
STAGE_BINDIR=$STAGE$BINDIR
STAGE_LIBDIR=$STAGE$LIBDIR
STAGE_LIBEXECDIR=$STAGE$LIBEXECDIR
STAGE_DATADIR=$STAGE$DATADIR
STAGE_REFERENCEDIR=$STAGE$REFERENCEDIR
STAGE_MANDIR=$STAGE$MANDIR
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"

DESTDIR="$STAGE" PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/install.sh" >"$TMP/install.log"

[ -f "$STAGE_DATADIR/csv/religion.csv" ]
[ -f "$STAGE_DATADIR/assets/parameter_aliases.tsv" ]
[ -f "$STAGE_DATADIR/assets/input_semantics_catalog.tsv" ]
[ -f "$STAGE_DATADIR/assets/reta_help_de.txt" ]
[ -f "$STAGE_DATADIR/assets/reta_help_en.txt" ]
[ -f "$STAGE_DATADIR/assets/i18n_words/deutsch.tsv" ]
[ -f "$STAGE_DATADIR/assets/i18n_words/manifest.json" ]
for manpage in $(reta_public_manpages); do
    [ -f "$STAGE_MANDIR/man1/$manpage" ]
done

# Only public user commands are installed.
for command in reta rp rpl rpe rpb generate_html grundStrukHtml; do
    [ -x "$STAGE_BINDIR/$command" ]
    [ ! -L "$STAGE_BINDIR/$command" ]
    [ ! -e "$STAGE_BINDIR/$command.reta-source-id" ]
    [ ! -e "$STAGE_LIBEXECDIR/$command" ]
    [ ! -e "$STAGE_LIBDIR/$command" ]
done
for forbidden in $(reta_artifact_legacy_installed_executables 2>/dev/null || true); do
    case "$forbidden" in
        reta|grundStrukHtml|rp|rpl|rpe|rpb|generate_html) continue ;;
    esac
    [ ! -e "$STAGE_BINDIR/$forbidden" ]
done
[ ! -e "$STAGE_BINDIR/mojo-runtime-exec" ]
[ ! -e "$STAGE_BINDIR/generate-html-native" ]
[ ! -e "$STAGE_BINDIR/reta-mojo" ]
[ ! -e "$STAGE_BINDIR/reta-native" ]

[ ! -e "$STAGE_LIBEXECDIR/python_reference" ]
[ ! -e "$STAGE_REFERENCEDIR" ]
[ ! -e "$STAGE_DATADIR/PYTHON_REFERENCE_LAYOUT" ]
[ ! -e "$STAGE_LIBEXECDIR/assets" ]
[ ! -e "$STAGE_LIBEXECDIR/bin" ]
[ ! -e "$STAGE_LIBEXECDIR/scripts" ]
[ ! -e "$STAGE_LIBEXECDIR/target" ]
[ ! -e "$STAGE_LIBEXECDIR/mojo" ]

for library_name in $(reta_artifact_core_shared_libraries); do
    [ -f "$STAGE_LIBDIR/$library_name" ]
    [ ! -x "$STAGE_LIBDIR/$library_name" ]
    [ ! -e "$STAGE_LIBDIR/$library_name.reta-source-id" ]
    [ ! -e "$STAGE_LIBEXECDIR/$library_name" ]
    [ ! -e "$STAGE_LIBEXECDIR/$library_name.reta-source-id" ]
done
for library_name in $(reta_artifact_prompt_shared_libraries); do
    [ -f "$STAGE_LIBDIR/$library_name" ]
    [ ! -x "$STAGE_LIBDIR/$library_name" ]
    [ ! -e "$STAGE_LIBDIR/$library_name.reta-source-id" ]
    [ ! -e "$STAGE_LIBEXECDIR/$library_name" ]
    [ ! -e "$STAGE_LIBEXECDIR/$library_name.reta-source-id" ]
done
[ ! -e "$STAGE_LIBDIR/libreta_diagnostics_mojo.so" ]
for runtime_library in \
    libKGENCompilerRTShared.so \
    libAsyncRTMojoBindings.so \
    libMSupportGlobals.so \
    libAsyncRTRuntimeGlobals.so \
    libNVPTX.so
 do
    [ -f "$STAGE_LIBDIR/$runtime_library" ]
    [ ! -x "$STAGE_LIBDIR/$runtime_library" ]
    [ ! -e "$STAGE_LIBEXECDIR/mojo/$runtime_library" ]
 done
! find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \( -name '*.reta-source-id' -o -name '*.reta-test-source-id' \) 2>/dev/null | grep -q .
! find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" "$STAGE_DATADIR" -type l 2>/dev/null | grep -q .

set -- \
    -zeilen --vorhervonausschnitt=1-2 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=csv --breite=40
# Do not execute python_reference/reta.py here.  The install-layout gate must
# stay independent from optional Python reference dependencies.  The fixture
# was generated from the historical reference once and is kept as inert data.
REFERENCE_FIXTURE="$ROOT/tests/fixtures/install_layout/reta_sternpolygon_csv_reference.txt"
[ -f "$REFERENCE_FIXTURE" ]
(
    cd "$TMP"
    "$STAGE_BINDIR/reta" "$@" >"$TMP/core-launcher.out"
)
cmp "$REFERENCE_FIXTURE" "$TMP/core-launcher.out"

(
    cd "$TMP"
    RETA_PYTHON=/definitely/not/available "$STAGE_BINDIR/reta" -h         >"$TMP/installed-help-de.out"
    RETA_PYTHON=/definitely/not/available "$STAGE_BINDIR/reta"         -language=english -h >"$TMP/installed-help-en.out"
)
cmp "$ROOT/assets/reta_help_de.txt" "$TMP/installed-help-de.out"
cmp "$ROOT/assets/reta_help_en.txt" "$TMP/installed-help-en.out"

(
    cd "$TMP"
    RETA_PROMPT_INTERACTIVE_LIBRARY=/definitely/missing/libreta_prompt_interactive_mojo.so \
        "$STAGE_BINDIR/rpb" prim 60 >"$TMP/installed-rpb.out"
    printf 'q\n' | "$STAGE_BINDIR/rp" >"$TMP/installed-rp.out"
)
grep -q '^60: 2\^2 3 5$' "$TMP/installed-rpb.out"

# The optional Python reference is a separate install/uninstall profile and is
# installed as inert data only.  Native profiles must keep working without it.
DESTDIR="$STAGE" PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/install.sh" --reference >"$TMP/install-reference.log"
[ -d "$STAGE_REFERENCEDIR" ]
[ -f "$STAGE_REFERENCEDIR/reta.py" ]
[ -d "$STAGE_REFERENCEDIR/reta_architecture" ]
! find "$STAGE_REFERENCEDIR" -type f -perm /111 2>/dev/null | grep -q .
[ -x "$STAGE_BINDIR/reta" ]
[ -f "$STAGE_DATADIR/csv/religion.csv" ]

DESTDIR="$STAGE" PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/uninstall.sh" --reference >"$TMP/uninstall-reference.log"
[ ! -e "$STAGE_REFERENCEDIR" ]
[ ! -e "$STAGE_DATADIR/PYTHON_REFERENCE_LAYOUT" ]
[ -x "$STAGE_BINDIR/reta" ]
[ -f "$STAGE_DATADIR/csv/religion.csv" ]

DESTDIR="$STAGE" PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/uninstall.sh" >/dev/null
for manpage in $(reta_public_manpages); do
    [ ! -e "$STAGE_MANDIR/man1/$manpage" ]
done
[ ! -e "$STAGE_LIBEXECDIR" ]
[ ! -e "$STAGE_DATADIR" ]
for command in reta rp rpl rpe rpb generate_html grundStrukHtml; do
    [ ! -e "$STAGE_BINDIR/$command" ]
done
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
    [ ! -e "$STAGE_LIBDIR/$library_name" ]
 done

printf '%s\n' 'FHS-Installation: öffentliche Befehle, benötigte Libraries und Deinstallation bestanden.'
