#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DEST=${1:-"$HOME/.local/bin"}
mkdir -p "$DEST"
for name in reta reta-native reta-mojo-boundaries reta-mojo-contracts reta-mojo-witnesses reta-mojo-coherence reta-mojo-traces reta-mojo-impact reta-mojo-migration reta.english retaPrompt retaPrompt.english rp rpl rpb rpe prim prim24 multis multis3 modulo math grundStrukHtml grundStrukHtml.py generate_html; do
    ln -sf "$ROOT/bin/$name" "$DEST/$name"
done
printf 'Reta/Mojo-Startprogramme wurden nach %s verlinkt.\n' "$DEST"
printf 'Falls nötig, ergänze PATH um: %s\n' "$DEST"
