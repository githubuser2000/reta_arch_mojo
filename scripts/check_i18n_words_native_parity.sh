#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/test-bin
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TARGET=target/test-bin/reta-mojo-i18n-parity
"$MOJO" build -I src src/i18n_words_main.mojo -o "$TARGET"
for language in deutsch english vietnamese chinese korean; do
    "$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET" --dump "$language" \
        > "target/test-bin/i18n-$language.dump"
    cmp "target/test-bin/i18n-$language.dump" "assets/i18n_words/$language.tsv"
done
printf '%s\n' 'native i18n.words tree parity: 5/5 languages, 68265/68265 rows'
