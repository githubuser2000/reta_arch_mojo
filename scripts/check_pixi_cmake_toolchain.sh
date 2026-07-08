#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
status=0

have_cmd() {
    name=$1
    label=${2:-$name}
    if command -v "$name" >/dev/null 2>&1; then
        printf 'OK   %-18s %s\n' "$label" "$(command -v "$name")"
        return 0
    fi
    printf 'MISS %-18s nicht im PATH\n' "$label" >&2
    status=1
    return 1
}

show_version() {
    label=$1
    shift
    if version=$($@ 2>&1 | head -n 1); then
        printf '     %-18s %s\n' "$label" "$version"
    fi
}

if command -v python >/dev/null 2>&1; then
    have_cmd python
    show_version python python --version
elif command -v python3 >/dev/null 2>&1; then
    have_cmd python3 python
    show_version python python3 --version
else
    printf 'MISS %-18s weder python noch python3 gefunden\n' python >&2
    status=1
fi

if have_cmd uv; then
    show_version uv uv --version
fi
if have_cmd cmake; then
    show_version cmake cmake --version
fi
if have_cmd ninja; then
    show_version ninja ninja --version
fi
if have_cmd pkg-config; then
    show_version pkg-config pkg-config --version
fi

if [ -n "${CC-}" ]; then
    printf 'OK   %-18s %s\n' CC "$CC"
elif command -v cc >/dev/null 2>&1; then
    printf 'OK   %-18s %s\n' cc "$(command -v cc)"
else
    printf 'MISS %-18s weder CC noch cc gefunden\n' c-compiler >&2
    status=1
fi

if [ -x "$ROOT/bin/mojo-real" ]; then
    if version=$("$ROOT/bin/mojo-real" --version 2>&1); then
        printf 'OK   %-18s %s\n' mojo-real "$ROOT/bin/mojo-real"
        printf '     %-18s %s\n' mojo "$(printf '%s\n' "$version" | head -n 1)"
    else
        printf 'MISS %-18s bin/mojo-real konnte keinen Modular-Mojo-Compiler starten\n' mojo-real >&2
        printf '%s\n' "$version" >&2
        status=1
    fi
else
    printf 'MISS %-18s %s nicht ausführbar\n' mojo-real "$ROOT/bin/mojo-real" >&2
    status=1
fi

if grep -Eq '^\[pypi-dependencies\]' "$ROOT/pixi.toml" 2>/dev/null && \
   awk '/^\[pypi-dependencies\]/{flag=1; next} /^\[/{flag=0} flag && $0 ~ /^mojo[[:space:]]*=/' "$ROOT/pixi.toml" | grep -q .; then
    printf 'MISS %-18s pixi.toml darf mojo nicht als PyPI-Abhängigkeit verwalten\n' pixi-mojo >&2
    status=1
else
    printf 'OK   %-18s Mojo wird extern über bin/mojo-real verwendet\n' pixi-mojo
fi

if [ "$status" -ne 0 ]; then
    cat >&2 <<'MSG'

Toolchain unvollständig.

Mojo wird absichtlich nicht als Pixi-PyPI-Abhängigkeit installiert.
Nutze eine vorhandene .venv/uv-Installation oder richte sie ein mit:

    pixi run setup-mojo-venv

Direkt ohne Pixi bleibt weiterhin gültig:

    scripts/build_core_shared.sh -- -j 8
MSG
    exit "$status"
fi

printf '\nToolchain-Prüfung erfolgreich. Es wurde nichts kompiliert.\n'
