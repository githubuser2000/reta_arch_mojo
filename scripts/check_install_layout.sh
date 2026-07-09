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
STAGE_LIBEXECDIR=$STAGE$LIBEXECDIR
STAGE_DATADIR=$STAGE$DATADIR
STAGE_REFERENCEDIR=$STAGE$REFERENCEDIR
STAGE_MANDIR=$STAGE$MANDIR
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"

DESTDIR="$STAGE" PREFIX="$PREFIX" BINDIR="$BINDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/install.sh" >"$TMP/install.log"

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
[ -x "$STAGE_BINDIR/reta-mojo-i18n" ]
[ ! -L "$STAGE_BINDIR/reta-mojo-i18n" ]
[ -x "$STAGE_BINDIR/reta-mojo-package-integrity" ]
[ ! -L "$STAGE_BINDIR/reta-mojo-package-integrity" ]
[ ! -e "$STAGE_LIBEXECDIR/python_reference" ]
[ -d "$STAGE_REFERENCEDIR" ]
[ -d "$STAGE_REFERENCEDIR/csv" ]
[ ! -L "$STAGE_REFERENCEDIR/csv" ]
[ -f "$STAGE_REFERENCEDIR/csv/religion.csv" ]
[ ! -e "$STAGE_LIBEXECDIR/assets" ]
[ ! -e "$STAGE_LIBEXECDIR/bin" ]
[ ! -e "$STAGE_LIBEXECDIR/scripts" ]
[ -x "$STAGE_BINDIR/mojo-runtime-exec" ]
for wrapper in $(reta_artifact_public_shell_wrappers); do
    [ -x "$STAGE_BINDIR/$wrapper" ]
    [ ! -L "$STAGE_BINDIR/$wrapper" ]
done
for starter in $(reta_artifact_core_starters); do
    [ -x "$STAGE_BINDIR/$starter" ]
    [ ! -L "$STAGE_BINDIR/$starter" ]
    [ ! -e "$STAGE_LIBEXECDIR/$starter" ]
    [ ! -e "$STAGE_BINDIR/$starter.reta-source-id" ]
    [ ! -e "$STAGE_LIBEXECDIR/$starter.reta-source-id" ]
done
for starter in $(reta_artifact_prompt_starters); do
    [ -x "$STAGE_BINDIR/$starter" ]
    [ ! -L "$STAGE_BINDIR/$starter" ]
    [ ! -e "$STAGE_LIBEXECDIR/$starter" ]
    [ ! -e "$STAGE_BINDIR/$starter.reta-source-id" ]
    [ ! -e "$STAGE_LIBEXECDIR/$starter.reta-source-id" ]
done
for library_name in $(reta_artifact_core_shared_libraries); do
    [ -f "$STAGE_LIBEXECDIR/$library_name" ]
    [ ! -e "$STAGE_LIBEXECDIR/$library_name.reta-source-id" ]
done
for library_name in $(reta_artifact_prompt_shared_libraries); do
    [ -f "$STAGE_LIBEXECDIR/$library_name" ]
    [ ! -e "$STAGE_LIBEXECDIR/$library_name.reta-source-id" ]
done
[ ! -e "$STAGE_LIBEXECDIR/target" ]
! find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \( -name '*.reta-source-id' -o -name '*.reta-test-source-id' \) | grep -q .
! find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" "$STAGE_DATADIR" -type l | grep -q .

(
    cd "$TMP"
    "$STAGE_BINDIR/reta-mojo" --mojo-csv-info >"$TMP/csv-info.out"
)
grep -q '^Zeilen: 1025$' "$TMP/csv-info.out"
grep -q '^Spalten: 746$' "$TMP/csv-info.out"


(
    cd "$TMP"
    "$STAGE_BINDIR/reta-mojo-i18n" --summary english >"$TMP/i18n-summary.out"
)
grep -q '^language=english$' "$TMP/i18n-summary.out"
grep -q '^rows=13655$' "$TMP/i18n-summary.out"
grep -q '^legacy_monolith_rows=6720$' "$TMP/i18n-summary.out"
grep -q '^matrix_rows=4766$' "$TMP/i18n-summary.out"

(
    cd "$TMP"
    "$STAGE_BINDIR/reta-mojo-package-integrity" --summary \
        "$STAGE_REFERENCEDIR" >"$TMP/package-integrity.out"
)
grep -q '^file_count=457$' "$TMP/package-integrity.out"
grep -q '^missing_required=0$' "$TMP/package-integrity.out"
grep -q '^suspicious_csvs=0$' "$TMP/package-integrity.out"

# The public HTML generator must be usable from an arbitrary, non-install
# working directory and must not create the historical middle.alx implicitly.
printf 'installed-middle\n' > "$TMP/middle.fixture"
cat "$ROOT/assets/html/head1.alx" \
    "$ROOT/assets/html/religionen.js" \
    "$ROOT/assets/html/head2.alx" \
    "$TMP/middle.fixture" \
    "$ROOT/tests/fixtures/grundstrukturen_html/blank-de.html" \
    "$ROOT/assets/html/footer.alx" > "$TMP/generate-html.expected"
mkdir -p "$TMP/caller"
(
    cd "$TMP/caller"
    "$STAGE_BINDIR/generate_html" \
        --middle-file "$TMP/middle.fixture" \
        --middle-output "$TMP/middle.saved" \
        --output "$TMP/generate-html.actual"
    "$STAGE_BINDIR/generate_html" --help > "$TMP/generate-html.help"
    "$STAGE_BINDIR/generate_html" --version > "$TMP/generate-html.version"
)
cmp "$TMP/generate-html.expected" "$TMP/generate-html.actual"
cmp "$TMP/middle.fixture" "$TMP/middle.saved"
[ ! -e "$TMP/caller/middle.alx" ]
grep -q -- '--middle-file' "$TMP/generate-html.help"
grep -q 'reta Mojo HTML generator' "$TMP/generate-html.version"

set -- \
    -zeilen --vorhervonausschnitt=1-2 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=csv --breite=40
(
    cd "$ROOT"
    python3 python_reference/reta.py "$@" >"$TMP/reference.out"
)
(
    cd "$TMP"
    "$STAGE_BINDIR/reta-native" "$@" >"$TMP/native.out"
    "$STAGE_BINDIR/reta" "$@" >"$TMP/core-launcher.out"
)
cmp "$TMP/reference.out" "$TMP/native.out"
cmp "$TMP/reference.out" "$TMP/core-launcher.out"

(
    cd "$TMP"
    RETA_PYTHON=/definitely/not/available "$STAGE_BINDIR/reta" -h         >"$TMP/installed-help-de.out"
    RETA_PYTHON=/definitely/not/available "$STAGE_BINDIR/reta"         -language=english -h >"$TMP/installed-help-en.out"
)
cmp "$ROOT/assets/reta_help_de.txt" "$TMP/installed-help-de.out"
cmp "$ROOT/assets/reta_help_en.txt" "$TMP/installed-help-en.out"

# Installed packages intentionally do not ship .reta-source-id sidecars, so the
# source-tree Prompt-Shared-Runtime check is not applicable here. The installed
# smoke below checks the public BINDIR launchers against LIBEXECDIR libraries.

(
    cd "$TMP"
    RETA_PROMPT_INTERACTIVE_LIBRARY=/definitely/missing/libreta_prompt_interactive_mojo.so \
        "$STAGE_BINDIR/rpb" prim 60 >"$TMP/installed-rpb.out"
    printf 'q\n' | "$STAGE_BINDIR/rp" >"$TMP/installed-rp.out"
)
grep -q '^60: 2\^2 3 5$' "$TMP/installed-rpb.out"
DESTDIR="$STAGE" PREFIX="$PREFIX" BINDIR="$BINDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/uninstall.sh" >/dev/null
for manpage in $(reta_public_manpages); do
    [ ! -e "$STAGE_MANDIR/man1/$manpage" ]
done
[ ! -e "$STAGE_LIBEXECDIR" ]
[ ! -e "$STAGE_DATADIR" ]

printf '%s\n' 'FHS-Installation: Layout, native CSV, Core-/Prompt-Starter und Deinstallation bestanden.'
