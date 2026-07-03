#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

# One durable entry point for every installable native artifact.  The heavy
# architecture owners are compiled first; the regular build then creates the
# user-facing programs and the shared diagnostic library.
"$ROOT/scripts/build-heavy.sh"
"$ROOT/scripts/build.sh"

printf '\n%s\n' 'Vollständiger nativer Build abgeschlossen.'
printf '%s\n' 'Erzeugt wurden alle regulären und schweren Executables sowie die Shared Libraries.'
printf '%s\n' 'Tests sind getrennt und optional: scripts/test_all.sh'
