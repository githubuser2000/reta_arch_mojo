#!/usr/bin/env sh
set -eu

usage() {
    cat <<'USAGE'
Verwendung: scripts/run_install_task.sh [--dry-run] TASK

Zentraler Einstiegspunkt für Installations-Tasks aus Shell, Pixi und CMake.
Alle Varianten verwenden dieselben Install-Defaults; standardmäßig ist das:

  PREFIX=/usr/local

Tasks:
  install | install-standard
  install-zusatz
  install-all
  uninstall | uninstall-all
  uninstall-standard
  uninstall-zusatz
  check-install-layout
  check-manpages
  install-layout

Mit --dry-run oder RETA_DRY_RUN=1 werden die Befehle nur angezeigt.
USAGE
}

case ${1:-} in
    --dry-run)
        RETA_DRY_RUN=1
        export RETA_DRY_RUN
        shift
        ;;
esac

case ${1:-} in
    -h|--help|'')
        usage
        exit 0
        ;;
esac

TASK=$1
shift
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_command_runner.sh"
reta_install_set_defaults

run_install_profile() {
    profile=$1
    reta_exec_or_print env PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/install.sh" "--$profile"
}

run_uninstall_profile() {
    profile=$1
    reta_exec_or_print env PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/uninstall.sh" "--$profile"
}

case $TASK in
    install|install-standard)
        run_install_profile standard
        ;;
    install-zusatz)
        run_install_profile zusatz
        ;;
    install-all)
        run_install_profile all
        ;;
    uninstall|uninstall-all)
        run_uninstall_profile all
        ;;
    uninstall-standard)
        run_uninstall_profile standard
        ;;
    uninstall-zusatz)
        run_uninstall_profile zusatz
        ;;
    check-install-layout)
        reta_exec_or_print env PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/check_install_layout.sh"
        ;;
    check-manpages)
        reta_exec_or_print "$ROOT/scripts/check_manpages.sh"
        ;;
    install-layout)
        reta_exec_or_print env PREFIX="$PREFIX" BINDIR="$BINDIR" LIBDIR="$LIBDIR" LIBEXECDIR="$LIBEXECDIR" DATADIR="$DATADIR" REFERENCEDIR="$REFERENCEDIR" MANDIR="$MANDIR" "$ROOT/scripts/print_install_layout.sh"
        ;;
    *)
        printf 'Unbekannter Install-Task: %s\n' "$TASK" >&2
        usage >&2
        exit 2
        ;;
esac
