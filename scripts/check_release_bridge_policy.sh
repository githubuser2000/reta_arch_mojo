#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
reta_install_set_defaults

fail() {
    printf 'Release-Bridge-Policy-Fehler: %s\n' "$*" >&2
    exit 1
}

# Native Standardinstallation: python_reference ist kein Runtime-Material.
grep -q 'standard, zusatz und all installieren python_reference bewusst nicht' scripts/install.sh || \
    fail 'install.sh dokumentiert die native python_reference-Trennung nicht'
grep -q 'if \[ "$INSTALL_PROFILE" = reference \]' scripts/install.sh || \
    fail 'install.sh hat keinen getrennten reference-Zweig'
[ "$(grep -c 'cp -aL "\$ROOT/python_reference"' scripts/install.sh)" = 1 ] || \
    fail 'python_reference darf nur einmal im reference-Zweig kopiert werden'

# Installed loaders must not synthesize RETA_REFERENCE_DIR unless --reference
# installed the directory. Source-tree development may still use python_reference.
for loader in tools/reta_core_loader.c tools/reta_prompt_loader.c; do
    grep -q 'directory_exists(reference)' "$loader" || \
        fail "$loader setzt RETA_REFERENCE_DIR nicht existenzgeprüft"
    grep -q '!installed_bin_layout &&' "$loader" || \
        fail "$loader darf installierte Befehle nicht auf PREFIX/python_reference/csv zurückfallen lassen"
    grep -q 'directory_exists(assets)' "$loader" || \
        fail "$loader setzt Asset-Fallback nicht existenzgeprüft"
done


# Release gates for the native install layout must not import the optional
# Python reference.  In particular they must not trigger pyphen/pkg_resources
# warnings from python_reference/reta.py.
! grep -q 'python3 python_reference/reta.py' scripts/check_install_layout.sh || \
    fail 'check_install_layout.sh darf python_reference/reta.py nicht ausführen'
! grep -qi 'pyphen' scripts/check_install_layout.sh || \
    fail 'check_install_layout.sh darf pyphen nicht verwenden oder erwähnen'


# Pyphen is not part of the active reference or native release path.  It was a
# historical optional hyphenation dependency, but the active table wrapping path
# uses deterministic hard chunking.  Do not reintroduce an import or dependency
# that makes release checks load pkg_resources through pyphen.
! grep -RIn --exclude-dir=.git --exclude-dir=target --exclude-dir=.venv --exclude-dir=.pixi \
    -E '^[[:space:]]*(import|from)[[:space:]]+pyphen([[:space:]]|$)' python_reference src tools scripts tests >/dev/null || \
    fail 'pyphen darf nicht importiert werden'
! grep -RIn --exclude-dir=.git --exclude-dir=target --exclude-dir=.venv --exclude-dir=.pixi \
    -E 'pyphen[[:space:]]*=|pip install[[:space:]]+pyphen|pyphen==' python_reference pyproject.toml setup.py 2>/dev/null >/dev/null || \
    fail 'pyphen darf nicht als aktive Abhängigkeit eingetragen werden'

# Standardprofile exposes only the real public commands.
for command in reta rp rpl rpe rpb generate_html grundStrukHtml; do
    reta_artifact_profile_install_executables standard | grep -qx "$command" || \
        fail "Standardprofil enthält öffentlichen Befehl nicht: $command"
done
for forbidden in reta-native reta-prompt-native reta-mojo reta-mojo-compat mojo-runtime-exec generate-html-native; do
    ! reta_artifact_profile_install_executables standard | grep -qx "$forbidden" || \
        fail "Standardprofil enthält Diagnose-/Bridge-Befehl: $forbidden"
done
! reta_artifact_profile_shared_libraries standard | grep -qx 'libreta_diagnostics_mojo.so' || \
    fail 'Standardprofil installiert Diagnose-Library'

# The default install target manifest intentionally tracks the standard profile.
TMP=${TMPDIR:-/tmp}/reta-bridge-policy.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
reta_artifact_profile_install_executables standard | sort >"$TMP/standard"
grep -v '^#' scripts/install_targets.txt | sed '/^[[:space:]]*$/d' | sort >"$TMP/install_targets"
cmp "$TMP/standard" "$TMP/install_targets" >/dev/null || \
    fail 'scripts/install_targets.txt entspricht nicht dem Standardprofil'

# Public user docs must not send users to Stage logs first.
grep -q '^# reta\.arch' README.md || fail 'README.md ist keine nutzerorientierte Hauptdatei'
grep -q 'PROJECT_STATUS_LOG.md' README.md || fail 'README.md verweist nicht auf den ausgelagerten Projektstatus'
grep -q 'PROJECT_STATUS_LOG.md' SOURCE_MANIFEST.sha256 || true

grep -q 'python_reference.*--reference\|--reference.*python_reference' README.md || \
    fail 'README.md erklärt python_reference nicht als explizites reference-Profil'

printf '%s\n' 'Release-Bridge-Policy: native Standardinstallation, Referenztrennung und öffentliche Profile sind hart geprüft.'
