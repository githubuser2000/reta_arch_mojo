#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-native-startup.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
COMPAT=${RETA_COMPAT_BINARY:-$ROOT/target/bin/reta-mojo-compat-bin}

[ -x "$COMPAT" ] || {
    printf 'Fehlendes Kompatibilitätsbinary: %s\n' "$COMPAT" >&2
    exit 2
}

compare() {
    label=$1
    shift
    (
        cd "$ROOT/python_reference"
        PYTHONHASHSEED=0 "$REFERENCE_PY" reta.py "$@"
    ) >"$TMP/reference-$label" 2>"$TMP/reference-$label.err"
    env RETA_PYTHON=/definitely/not/available \
        "$ROOT/bin/mojo-runtime-exec" "$COMPAT" "$@" \
        >"$TMP/native-$label" 2>"$TMP/native-$label.err"
    cmp "$TMP/reference-$label" "$TMP/native-$label"
    cmp "$TMP/reference-$label.err" "$TMP/native-$label.err"
    printf '%-28s %7s Byte\n' "$label" "$(wc -c <"$TMP/native-$label")"
}

compare empty
compare language-english -language=english
compare language-german -language=german
compare help-german -h
compare help-english -language=english -help
compare help-duplicate -help -h
compare help-first-language -h -language=english -language=german

printf '%s\n' 'Native Start-/Hilfe-Parität: 7/7.'
