#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
reta_install_set_defaults

printf 'prefix=%s\n' "$PREFIX"
printf 'destdir=%s\n' "$DESTDIR"
printf 'bindir=%s\n' "$BINDIR"
printf 'binarydir=%s\n' "$BINDIR"
printf 'libexecdir=%s\n' "$LIBEXECDIR"
printf 'sharedlibdir=%s\n' "$LIBEXECDIR"
printf 'datadir=%s\n' "$DATADIR"
printf 'csvdir=%s\n' "$DATADIR/csv"
printf 'assetdir=%s\n' "$DATADIR/assets"
printf 'referencedir=%s\n' "$REFERENCEDIR"
printf 'mandir=%s\n' "$MANDIR"
