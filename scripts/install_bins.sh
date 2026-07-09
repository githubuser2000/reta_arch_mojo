#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
: "${PREFIX:=/usr/local}"
printf '%s\n' 'scripts/install_bins.sh ist nur noch ein Kompatibilitäts-Einstieg.'
printf 'Installiere über das offizielle Layout nach PREFIX=%s.\n' "$PREFIX"
exec env PREFIX="$PREFIX" "$ROOT/scripts/install.sh"
