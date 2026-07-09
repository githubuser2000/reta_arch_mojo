#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

unset CC CXX LD AR AS RANLIB STRIP NM OBJCOPY OBJDUMP
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
unset LIBRARY_PATH CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
unset CONDA_PREFIX CONDA_BUILD_SYSROOT

export PATH="$ROOT/bin:$ROOT/.venv/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

exec "$@"
