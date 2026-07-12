#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-no-blank-contents.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=$("$ROOT/scripts/select_reference_python.sh")
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
FIXTURES="$ROOT/tests/fixtures/no_blank_contents"
[ -x "$NATIVE" ] || {
    printf 'Fehlender nativer Tabellenlauncher: %s\n' "$NATIVE" >&2
    exit 1
}

refresh_de() {
    mode=$1
    suffix=$2
    fixture="$FIXTURES/$mode-$suffix.out"
    if [ "${RETA_REFRESH_NO_BLANK_FIXTURES:-0}" = 1 ]; then
        extra=
        [ "$suffix" = noempty ] && extra=--keineleereninhalte
        # shellcheck disable=SC2086
        env PYTHONHASHSEED="$HASH_SEED" "$REFERENCE_PY" \
            python_reference/reta.py \
            -zeilen --vorhervonausschnitt=1-20 \
            -spalten --Menschliches=manipulation \
            -ausgabe --art="$mode" --breite=40 --onetable $extra \
            >"$fixture"
    fi
}

run_de() {
    mode=$1
    suffix=$2
    fixture="$FIXTURES/$mode-$suffix.out"
    [ -f "$fixture" ] || {
        printf 'Fehlendes No-blank-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
    extra=
    [ "$suffix" = noempty ] && extra=--keineleereninhalte
    # Ownership is verified separately by test_native_reta_cli.mojo.  This
    # direct binary comparison proves the rendered bytes without any fallback.
    # shellcheck disable=SC2086
    "$NATIVE" \
        -zeilen --vorhervonausschnitt=1-20 \
        -spalten --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=40 --onetable $extra \
        >"$TMP/$mode-$suffix.out"
    cmp "$fixture" "$TMP/$mode-$suffix.out"
    printf '  %-25s bytegleich (%s Byte)\n' \
        "$mode-$suffix" "$(wc -c <"$TMP/$mode-$suffix.out")"
}

mkdir -p "$FIXTURES"
for mode in shell html bbcode csv markdown emacs; do
    refresh_de "$mode" default
    refresh_de "$mode" noempty
    run_de "$mode" default
    run_de "$mode" noempty
done

english_fixture="$FIXTURES/html-english-noempty.out"
if [ "${RETA_REFRESH_NO_BLANK_FIXTURES:-0}" = 1 ]; then
    env PYTHONHASHSEED="$HASH_SEED" "$REFERENCE_PY" \
        python_reference/reta.py \
        -language=english -lines --thisrangebefore=1-20 \
        -columns --human=manipulation \
        -output --type=html --width=40 --onetable --noblankcontents \
        >"$english_fixture"
fi
[ -f "$english_fixture" ] || {
    printf 'Fehlendes englisches No-blank-Fixture: %s\n' "$english_fixture" >&2
    exit 1
}
"$NATIVE" \
    -language=english -lines --thisrangebefore=1-20 \
    -columns --human=manipulation \
    -output --type=html --width=40 --onetable --noblankcontents \
    >"$TMP/html-english-noempty.out"
cmp "$english_fixture" "$TMP/html-english-noempty.out"
printf '  %-25s bytegleich (%s Byte)\n' \
    html-english-noempty "$(wc -c <"$TMP/html-english-noempty.out")"

printf '%s\n' 'Native keineleereninhalte-Parität: 13/13 im direkten Mojo-Tabellenkern.'
