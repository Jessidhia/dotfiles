
function _gopath_push () {
    for i in "$@"; do
        if [[ "$OSTYPE" = "cygwin" ]]; then
            export GOPATH="$GOPATH${GOPATH:+;}$(cygpath -m "$i")"
        else
            export GOPATH="$GOPATH${GOPATH:+:}$i"
        fi
        export PATH="$i/bin:$PATH"
    done
}

[[ -z "$GOPATH" ]] && _gopath_push "$HOME/go"
