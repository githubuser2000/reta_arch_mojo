#!/usr/bin/env sh
# Shared POSIX-shell validation for user-supplied `mojo build` options.
#
# The public build scripts preserve the exact argument vector.  They only need
# to know whether the caller already selected a compiler thread count, because
# three very large targets otherwise add their conservative local `-j 4`
# default.  Mojo rejects two thread-count options even when the values match.

mojo_thread_option_count() {
    _reta_mojo_thread_count=0
    _reta_mojo_expect_thread_value=0
    for _reta_mojo_option do
        if [ "$_reta_mojo_expect_thread_value" -eq 1 ]; then
            _reta_mojo_expect_thread_value=0
            continue
        fi
        case $_reta_mojo_option in
            -j|--jobs|--threads)
                _reta_mojo_thread_count=$((_reta_mojo_thread_count + 1))
                _reta_mojo_expect_thread_value=1
                ;;
            -j[0-9]*|--jobs=*|--threads=*)
                _reta_mojo_thread_count=$((_reta_mojo_thread_count + 1))
                ;;
        esac
    done
    printf '%s\n' "$_reta_mojo_thread_count"
}

mojo_validate_build_options() {
    _reta_mojo_thread_count=$(mojo_thread_option_count "$@")
    if [ "$_reta_mojo_thread_count" -gt 1 ]; then
        printf '%s\n' \
            'Mojo-Compileroption für die Threadanzahl wurde mehrfach angegeben.' \
            'Bitte genau eine Form verwenden, zum Beispiel: -j 8' >&2
        return 2
    fi
}

mojo_has_thread_option() {
    _reta_mojo_thread_count=$(mojo_thread_option_count "$@")
    [ "$_reta_mojo_thread_count" -gt 0 ]
}
