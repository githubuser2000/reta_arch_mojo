#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMPDIR_BASE=${TMPDIR:-/tmp}/reta-generated-parity.$$
mkdir -p "$TMPDIR_BASE"
trap 'rm -rf "$TMPDIR_BASE"' EXIT HUP INT TERM
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
PYTHON_HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
[ -x "$NATIVE" ] || NATIVE="$ROOT/bin/reta-native"

run_pair() {
    label=$1
    shift
    env PYTHONHASHSEED="$PYTHON_HASH_SEED" "$REFERENCE_PY" python_reference/reta.py "$@" >"$TMPDIR_BASE/python-$label"
    "$NATIVE" "$@" >"$TMPDIR_BASE/mojo-$label"
    cmp "$TMPDIR_BASE/python-$label" "$TMPDIR_BASE/mojo-$label"
    printf '  %-24s bytegleich (%s Byte)\n' "$label" "$(wc -c <"$TMPDIR_BASE/mojo-$label")"
}

run_pair gestirn-de \
    -zeilen --vorhervonausschnitt=1-6 \
    -spalten --bedeutung=gestirn \
    -ausgabe --art=csv --breite=40
run_pair gleichheit-de \
    -zeilen --vorhervonausschnitt=1-8 \
    -spalten --menschliches=gleichheit \
    -ausgabe --art=csv --breite=40
run_pair geist-de \
    -zeilen --vorhervonausschnitt=1-8 \
    -spalten --grundstrukturen=geist \
    -ausgabe --art=csv --breite=40
run_pair primvielfache-de \
    -zeilen --vorhervonausschnitt=1-8 \
    -spalten --bedeutung=primzahlen \
    -ausgabe --art=csv --breite=40
run_pair gestirn-en \
    -language=english -lines --thisrangebefore=1-6 \
    -columns --meaning=spaceObject \
    -output --type=csv --width=40
run_pair modal-liebe-de \
    -zeilen --vorhervonausschnitt=1-40 \
    -spalten --grundstrukturen=liebe \
    -ausgabe --art=csv --breite=40
run_pair modal-love-en \
    -language=english -lines --thisrangebefore=1-40 \
    -columns --basic_structures=love \
    -output --type=csv --width=40
run_pair primzahlkreuz-de \
    -zeilen --vorhervonausschnitt=1-30 \
    -spalten --bedeutung=primzahlkreuz \
    -ausgabe --art=csv --breite=40
run_pair primecross-en \
    -language=english -lines --thisrangebefore=1-30 \
    -columns --meaning=primecross \
    -output --type=csv --width=40
run_pair primwirkung-de \
    -zeilen --vorhervonausschnitt=1-12 \
    -spalten --primzahlwirkung=absicht \
    -ausgabe --art=csv --breite=40
run_pair prime-effect-en \
    -language=english -lines --thisrangebefore=1-12 \
    -columns --prime_effect=intentions \
    -output --type=csv --width=40
run_pair primwirkung-alle-de \
    -zeilen --vorhervonausschnitt=1-20 \
    -spalten --primzahlwirkung=richtungrichtung,strukturalien,absicht,absichtreziproke,universumreziproke,dagegengegentranszendentalien,neutralegegentranszendentalien \
    -ausgabe --art=csv --breite=40
run_pair primuniversum-motivstern-de \
    -zeilen --vorhervonausschnitt=1-12 \
    -spalten --multiplikationen=motivstern \
    -ausgabe --art=csv --breite=40
run_pair prime-universe-motif-star-en \
    -language=english -lines --thisrangebefore=1-8 \
    -columns --multiplications=Motifs_starpolygons \
    -output --type=csv --width=40
run_pair primuniversum-alle-de \
    -zeilen --vorhervonausschnitt=1-12 \
    -spalten --multiplikationen=motivstern,strukturstern,motivgleichfoermig,strukturgleichfoermig \
    -ausgabe --art=csv --breite=40
run_pair primuniversum-gebr-motivstern-de \
    -zeilen --vorhervonausschnitt=1-8 \
    -spalten --multiplikationen=motivgebrstern \
    -ausgabe --art=csv --breite=40
run_pair prime-universe-fractional-motif-star-en \
    -language=english -lines --thisrangebefore=1-3 \
    -columns --multiplications=motifStar \
    -output --type=csv --width=40
run_pair primuniversum-gebr-alle-de \
    -zeilen --vorhervonausschnitt=1-4 \
    -spalten --multiplikationen=motivgebrstern,strukgebrstern,motivgebrgleichf,strukgebrgleichf \
    -ausgabe --art=csv --breite=40
run_pair primcsv-beschrieben-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --multiplikationen=beschrieben \
    -ausgabe --art=csv --breite=40
run_pair primcsv-described-en \
    -language=english -lines --thisrangebefore=1-3 \
    -columns --multiplications=described \
    -output --type=csv --width=40
run_pair markdown-baseline \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=markdown --breite=40
run_pair emacs-baseline \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=emacs --breite=40

printf '%s\n' 'Native Generator- und Rendererparität bestanden.'
