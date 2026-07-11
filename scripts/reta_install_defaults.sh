#!/usr/bin/env sh
# Shared install-layout defaults for shell, Pixi and CMake entrypoints.
# Source this file after ROOT is set when a script also needs repository paths.

reta_install_set_defaults() {
    : "${PREFIX:=/usr/local}"
    : "${DESTDIR:=}"
    : "${BINDIR:=$PREFIX/bin}"
    : "${LIBDIR:=$PREFIX/lib}"
    # Legacy private library directory. New installs keep every .so flat in LIBDIR;
    # this path is retained only so uninstall/install can clean older layouts.
    : "${LIBEXECDIR:=$PREFIX/lib/reta}"
    : "${DATADIR:=$PREFIX/share/reta}"
    : "${REFERENCEDIR:=$DATADIR/python_reference}"
    : "${MANDIR:=$PREFIX/share/man}"
}
