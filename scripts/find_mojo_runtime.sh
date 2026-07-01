#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

is_runtime_dir() {
    candidate=$1
    [ -d "$candidate" ] || return 1
    [ -f "$candidate/libKGENCompilerRTShared.so" ] || return 1
    [ -f "$candidate/libAsyncRTMojoBindings.so" ] || return 1
}

emit_if_runtime() {
    candidate=$1
    if is_runtime_dir "$candidate"; then
        (CDPATH= cd -- "$candidate" && pwd)
        exit 0
    fi
}

if [ -n "${RETA_MOJO_RUNTIME_LIBDIR-}" ]; then
    if is_runtime_dir "$RETA_MOJO_RUNTIME_LIBDIR"; then
        emit_if_runtime "$RETA_MOJO_RUNTIME_LIBDIR"
    fi
    printf 'RETA_MOJO_RUNTIME_LIBDIR enthält keine vollständige Mojo-Laufzeit: %s\n' \
        "$RETA_MOJO_RUNTIME_LIBDIR" >&2
    exit 2
fi

# Project-local installations. Both lib/ and lib64/ are used by common venvs.
for candidate in \
    "$ROOT"/.venv/lib/python*/site-packages/modular/lib \
    "$ROOT"/.venv/lib64/python*/site-packages/modular/lib \
    "$ROOT"/.pixi/envs/default/lib/python*/site-packages/modular/lib \
    "$ROOT"/.pixi/envs/default/lib64/python*/site-packages/modular/lib
 do
    [ -d "$candidate" ] || continue
    emit_if_runtime "$candidate"
 done

runtime_from_mojo() {
    mojo_candidate=$1
    [ -n "$mojo_candidate" ] || return 1
    [ -x "$mojo_candidate" ] || return 1

    resolved=$mojo_candidate
    if command -v readlink >/dev/null 2>&1; then
        resolved=$(readlink -f "$mojo_candidate" 2>/dev/null || printf '%s' "$mojo_candidate")
    fi

    # A package-internal native compiler normally sits in modular/bin.
    native_neighbor=$(CDPATH= cd -- "$(dirname -- "$resolved")/../lib" 2>/dev/null && pwd || true)
    if [ -n "$native_neighbor" ] && is_runtime_dir "$native_neighbor"; then
        printf '%s\n' "$native_neighbor"
        return 0
    fi

    # The venv console entry point is a Python script. Ask its interpreter for
    # the sibling modular/lib directory without importing project code.
    first_line=$(sed -n '1p' "$resolved" 2>/dev/null || true)
    case "$first_line" in
        '#!'*) python_candidate=${first_line#\#!} ;;
        *) python_candidate= ;;
    esac
    if [ -n "$python_candidate" ] && [ -x "$python_candidate" ]; then
        discovered=$(
            "$python_candidate" - <<'PY' 2>/dev/null || true
from pathlib import Path
try:
    import mojo
except Exception:
    raise SystemExit(1)
site_packages = Path(mojo.__file__).resolve().parent.parent
candidate = site_packages / "modular" / "lib"
print(candidate)
PY
        )
        if [ -n "$discovered" ] && is_runtime_dir "$discovered"; then
            (CDPATH= cd -- "$discovered" && pwd)
            return 0
        fi
    fi
    return 1
}

for mojo_candidate in \
    "${MOJO_BIN-}" \
    "$ROOT/.venv/bin/mojo" \
    "$ROOT/.pixi/envs/default/bin/mojo" \
    "${VIRTUAL_ENV-}/bin/mojo"
 do
    [ -n "$mojo_candidate" ] || continue
    if runtime_from_mojo "$mojo_candidate"; then
        exit 0
    fi
 done

path_mojo=$(command -v mojo 2>/dev/null || true)
if [ -n "$path_mojo" ] && runtime_from_mojo "$path_mojo"; then
    exit 0
fi

# uv may keep an unpacked compiler wheel outside the active environment.
for candidate in "$HOME"/.cache/uv/archive-v0/*/mojo_compiler-*.data/platlib/modular/lib
 do
    [ -d "$candidate" ] || continue
    emit_if_runtime "$candidate"
 done

cat >&2 <<'MSG'
Keine vollständige Modular-Mojo-Laufzeit gefunden.

Einmalig lokal einrichten:
    ./scripts/setup_mojo.sh

Oder den vorhandenen Ort explizit angeben:
    RETA_MOJO_RUNTIME_LIBDIR=/pfad/zu/modular/lib ./reta ...
MSG
exit 127
