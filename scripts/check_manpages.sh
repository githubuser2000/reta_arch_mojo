#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_manpages.sh"

for manpage in $(reta_all_manpages); do
    path="$ROOT/man/$manpage"
    [ -f "$path" ] || {
        printf 'Fehlende Manpage: %s\n' "$path" >&2
        exit 2
    }
    grep -q '^\.TH ' "$path" || {
        printf 'Manpage ohne .TH-Kopf: %s\n' "$path" >&2
        exit 2
    }
    grep -q '^\.SH NAME' "$path" || {
        printf 'Manpage ohne NAME-Abschnitt: %s\n' "$path" >&2
        exit 2
    }
    grep -q '^\.SH SYNOPSIS' "$path" || {
        printf 'Manpage ohne SYNOPSIS-Abschnitt: %s\n' "$path" >&2
        exit 2
    }
done

grep -q 'main parameters start with one dash' "$ROOT/man/reta.1"
grep -q 'interactive Reta prompt' "$ROOT/man/rp.1"
grep -q 'compact logged Reta prompt profile' "$ROOT/man/rpl.1"
grep -q 'Emacs-style output' "$ROOT/man/rpe.1"
grep -q 'one-shot Reta prompt frontend' "$ROOT/man/rpb.1"
grep -q -- '--middle-file' "$ROOT/man/generate_html.1"

printf 'Manpages konsistent: %s Dateien\n' "$(reta_all_manpages | wc -l | tr -d ' ')"
