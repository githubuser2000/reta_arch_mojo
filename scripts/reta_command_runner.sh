#!/usr/bin/env sh
# Shared command execution helper for Shell/Pixi/CMake entrypoints.
# POSIX-sh only.  Keep this file small: it is sourced by task wrappers.

reta_dry_run_enabled() {
    case ${RETA_DRY_RUN:-0} in
        1|true|TRUE|yes|YES|on|ON)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

reta_quote_arg() {
    # Human-readable shell-ish quoting for plans.  This is for display only;
    # execution always uses the original argv vector.
    case $1 in
        '')
            printf "''"
            ;;
        *[!A-Za-z0-9_./:=,+@%-]*)
            printf "'"
            printf '%s' "$1" | sed "s/'/'\\''/g"
            printf "'"
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

reta_print_command() {
    printf '+ '
    _reta_first=1
    for _reta_arg do
        if [ "$_reta_first" = 1 ]; then
            _reta_first=0
        else
            printf ' '
        fi
        reta_quote_arg "$_reta_arg"
    done
    printf '\n'
}

reta_run_or_print() {
    if reta_dry_run_enabled; then
        reta_print_command "$@"
        return 0
    fi
    "$@"
}

reta_exec_or_print() {
    if reta_dry_run_enabled; then
        reta_print_command "$@"
        return 0
    fi
    exec "$@"
}
