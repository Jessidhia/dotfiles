
function wrap_exe() {
    exe="$1"
    semicolon="$(test "$2" = "&" && echo "&" || echo ";")"

    if ! [ -f "$1" ]; then
        exe="$(which "$1")"
        if [ "$?" -ne 0 ]; then
            echo "command not found: $1" >/dev/stderr
            return 1;
        fi
    fi

    alias="$(basename "$1" .exe)"

    eval 'function '$alias'() { "$HOME/bin/exe_wrapper.pl" "'$exe'" "$@"'$semicolon' }'

    echo "Wrapped \"$1\" as \"$alias\""
}
