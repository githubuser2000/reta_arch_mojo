#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_artifacts.sh"

TMP=${TMPDIR:-/tmp}/reta-artifact-manifest.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"

expected_targets=$TMP/install-targets.expected
actual_targets=$TMP/install-targets.actual

reta_artifact_install_executables > "$expected_targets"
grep -Ev '^[[:space:]]*($|#)' "$(reta_artifact_install_target_file "$ROOT")" > "$actual_targets"

if ! cmp -s "$expected_targets" "$actual_targets"; then
    printf '%s\n' 'Fehler: scripts/install_targets.txt weicht vom zentralen Artefaktmanifest ab.' >&2
    printf '%s\n' 'Diff:' >&2
    diff -u "$expected_targets" "$actual_targets" >&2 || true
    exit 1
fi

# Shared libraries are not listed in install_targets.txt because they are
# installed through the ABI-aware library path.  Still assert the central
# manifest exposes each expected ABI group.
[ "$(reta_artifact_core_shared_libraries | wc -l | tr -d ' ')" -ge 1 ]
[ "$(reta_artifact_prompt_shared_libraries | wc -l | tr -d ' ')" -ge 2 ]
[ "$(reta_artifact_diagnostics_shared_libraries | wc -l | tr -d ' ')" -ge 1 ]

printf '%s\n' 'Artefaktmanifest konsistent:'
printf '  install_targets.txt: %s Ziele\n' "$(wc -l < "$actual_targets" | tr -d ' ')"
printf '  shared libraries:     %s Ziele\n' "$(reta_artifact_shared_libraries | wc -l | tr -d ' ')"
