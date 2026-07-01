#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=${TMPDIR:-/tmp}/reta-resource-paths.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
"$ROOT/bin/mojo-real" build -I "$ROOT/src" \
    "$ROOT/tests/resource_paths_probe.mojo" -o "$TMP/probe"

assert_output() {
    label=$1
    expected=$2
    shift 2
    "$@" >"$TMP/$label.out"
    printf '%s\n' "$expected" >"$TMP/$label.expected"
    cmp "$TMP/$label.expected" "$TMP/$label.out"
}

assert_output defaults 'root=
share=
csv=python_reference/csv
asset=assets
reference=python_reference
religion=python_reference/csv/religion.csv
aliases=assets/parameter_aliases.tsv' \
    env -u RETA_ROOT -u RETA_SHARE_DIR -u RETA_DATA_DIR \
        -u RETA_ASSET_DIR -u RETA_REFERENCE_DIR "$TMP/probe"

assert_output shared 'root=/opt/reta
share=/usr/share/reta
csv=/usr/share/reta/csv
asset=/usr/share/reta/assets
reference=/opt/reta/python_reference
religion=/usr/share/reta/csv/religion.csv
aliases=/usr/share/reta/assets/parameter_aliases.tsv' \
    env -u RETA_DATA_DIR -u RETA_ASSET_DIR -u RETA_REFERENCE_DIR \
        RETA_ROOT=/opt/reta RETA_SHARE_DIR=/usr/share/reta "$TMP/probe"

assert_output overrides 'root=/opt/reta
share=/usr/share/reta
csv=/srv/reta-csv
asset=/srv/reta-assets
reference=/srv/reta-python
religion=/srv/reta-csv/religion.csv
aliases=/srv/reta-assets/parameter_aliases.tsv' \
    env RETA_ROOT=/opt/reta RETA_SHARE_DIR=/usr/share/reta \
        RETA_DATA_DIR=/srv/reta-csv RETA_ASSET_DIR=/srv/reta-assets \
        RETA_REFERENCE_DIR=/srv/reta-python "$TMP/probe"

printf '%s\n' 'Portable Ressourcenpfade: 3/3.'
