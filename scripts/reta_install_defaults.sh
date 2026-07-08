#!/usr/bin/env sh
# Shared install-layout defaults for shell, Pixi and CMake entrypoints.
# Source this file after ROOT is set when a script also needs repository paths.

reta_install_set_defaults() {
    : "${PREFIX:=/usr/local}"
    : "${DESTDIR:=}"
    : "${BINDIR:=$PREFIX/bin}"
    : "${LIBEXECDIR:=$PREFIX/lib/reta}"
    : "${DATADIR:=$PREFIX/share/reta}"
    : "${MANDIR:=$PREFIX/share/man}"
}
