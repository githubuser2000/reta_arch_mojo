#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
. "$ROOT/scripts/reta_manpages.sh"
reta_install_set_defaults

fail() {
    printf 'Installprofil-Matrixfehler: %s\n' "$*" >&2
    exit 1
}

check_list_subset_exact() {
    profile=$1
    expected_file=$2
    actual_file=$3
    sort "$expected_file" >"$expected_file.sorted"
    sort "$actual_file" >"$actual_file.sorted"
    cmp "$expected_file.sorted" "$actual_file.sorted" >/dev/null || {
        printf 'Erwartet (%s):\n' "$profile" >&2
        cat "$expected_file.sorted" >&2
        printf 'Ist (%s):\n' "$profile" >&2
        cat "$actual_file.sorted" >&2
        fail "Profil $profile installiert nicht die erwartete Befehlsmenge"
    }
}

TMP=${TMPDIR:-/tmp}/reta-install-profile-matrix.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"

reta_artifact_profile_install_executables standard >"$TMP/standard.commands"
reta_artifact_profile_install_executables zusatz >"$TMP/zusatz.commands"
reta_artifact_profile_install_executables all >"$TMP/all.commands"
reta_artifact_profile_install_executables reference >"$TMP/reference.commands"
reta_artifact_profile_shared_libraries standard >"$TMP/standard.libs"
reta_artifact_profile_shared_libraries zusatz >"$TMP/zusatz.libs"
reta_artifact_profile_shared_libraries all >"$TMP/all.libs"
reta_artifact_profile_shared_libraries reference >"$TMP/reference.libs"
reta_profile_manpages standard >"$TMP/standard.man"
reta_profile_manpages zusatz >"$TMP/zusatz.man"
reta_profile_manpages all >"$TMP/all.man"
reta_profile_manpages reference >"$TMP/reference.man"

cat >"$TMP/expected-standard.commands" <<'COMMANDS'
generate_html
grundStrukHtml
reta
rp
rpb
rpe
rpl
COMMANDS
check_list_subset_exact standard "$TMP/expected-standard.commands" "$TMP/standard.commands"
[ ! -s "$TMP/reference.commands" ] || fail 'reference darf keine Befehle installieren'
[ ! -s "$TMP/reference.libs" ] || fail 'reference darf keine Shared Libraries installieren'
[ ! -s "$TMP/reference.man" ] || fail 'reference darf keine Manpages installieren'

grep -qx 'libreta_core_mojo.so' "$TMP/standard.libs" || fail 'standard braucht libreta_core_mojo.so'
grep -qx 'libreta_prompt_mojo.so' "$TMP/standard.libs" || fail 'standard braucht libreta_prompt_mojo.so'
grep -qx 'libreta_prompt_interactive_mojo.so' "$TMP/standard.libs" || fail 'standard braucht libreta_prompt_interactive_mojo.so'
! grep -qx 'libreta_diagnostics_mojo.so' "$TMP/standard.libs" || fail 'standard darf libreta_diagnostics_mojo.so nicht installieren'
grep -qx 'libreta_diagnostics_mojo.so' "$TMP/zusatz.libs" || fail 'zusatz braucht Diagnose-Lib'
grep -qx 'libreta_diagnostics_mojo.so' "$TMP/all.libs" || fail 'all braucht Diagnose-Lib'

for command in $(cat "$TMP/standard.commands"); do
    grep -qx "$command" "$TMP/zusatz.commands" || fail "zusatz enthält Standardbefehl nicht: $command"
    grep -qx "$command" "$TMP/all.commands" || fail "all enthält Standardbefehl nicht: $command"
done
for command in $(cat "$TMP/zusatz.commands"); do
    grep -qx "$command" "$TMP/all.commands" || fail "all enthält Zusatzbefehl nicht: $command"
done
for manpage in $(cat "$TMP/standard.man"); do
    grep -qx "$manpage" "$TMP/zusatz.man" || fail "zusatz enthält Standard-Manpage nicht: $manpage"
    grep -qx "$manpage" "$TMP/all.man" || fail "all enthält Standard-Manpage nicht: $manpage"
done
for manpage in $(cat "$TMP/zusatz.man"); do
    grep -qx "$manpage" "$TMP/all.man" || fail "all enthält Zusatz-Manpage nicht: $manpage"
done

# Shell, Pixi and CMake must call the same run_install_task.sh/install.sh path.
for task in install install-zusatz install-all install-reference uninstall-standard uninstall-zusatz uninstall-all uninstall-reference; do
    RETA_DRY_RUN=1 "$ROOT/scripts/run_install_task.sh" "$task" >"$TMP/$task.dry"
    grep -q "PREFIX=$PREFIX" "$TMP/$task.dry" || fail "Task $task verliert PREFIX=$PREFIX"
    grep -q "BINDIR=$BINDIR" "$TMP/$task.dry" || fail "Task $task verliert BINDIR=$BINDIR"
    grep -q "LIBDIR=$LIBDIR" "$TMP/$task.dry" || fail "Task $task verliert LIBDIR=$LIBDIR"
    grep -q "DATADIR=$DATADIR" "$TMP/$task.dry" || fail "Task $task verliert DATADIR=$DATADIR"
done

grep -q 'install = "scripts/run_install_task.sh install"' pixi.toml || fail 'Pixi install nutzt nicht run_install_task.sh'
grep -q 'install-all = "scripts/run_install_task.sh install-all"' pixi.toml || fail 'Pixi install-all fehlt'
grep -q 'install-reference = "scripts/run_install_task.sh install-reference"' pixi.toml || fail 'Pixi install-reference fehlt'
grep -q 'COMMAND ${CMAKE_COMMAND} -E env PREFIX=${RETA_INSTALL_PREFIX} scripts/run_install_task.sh install' CMakeLists.txt || fail 'CMake standard install nutzt nicht run_install_task.sh'
grep -q 'reta-install-all' CMakeLists.txt || fail 'CMake install-all Target fehlt'
grep -q 'reta-install-reference' CMakeLists.txt || fail 'CMake install-reference Target fehlt'

printf '%s\n' 'Installprofil-Matrix: Shell, Pixi, CMake, Befehle, Libraries und Manpages konsistent.'
