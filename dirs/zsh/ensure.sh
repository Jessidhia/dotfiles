minimum_zsh_version='5.7.0'

# https://stackoverflow.com/a/4025065
version_compare () {
    if [[ "$1" == "$2" ]]; then
        return 0
    fi

    # on Cygwin, it's possible that the $SYSTEMROOT/system32/sort is ahead of /bin/sort in the PATH
    local SORT_CMD="$(if [[ $OSTYPE = cygwin ]]; then echo /bin/sort; else echo sort; fi)"
    if [[ "$(echo -e "$1\n$2" | "$SORT_CMD" -t '.' -k 1,1 -k 2,2 -k 3,3 -n | head -n 1)" == "$2" ]]; then
      return 1
    fi

    return 2
}

build_zsh() {
    BUILD_DIR="$(mktemp -d)"
    cd "$BUILD_DIR"
    umask 022
    curl -L 'https://sourceforge.net/projects/zsh/files/latest/download' | tar xJf -
    cd ./zsh*/
    if ./configure --prefix="$HOME/.local" && \
        make && \
        make install
    then
        cd "$HOME"
        rm -rf "$BUILD_DIR"
        return 0
    else
        cd "$HOME"
        rm -rf "$BUILD_DIR"
        return 1
    fi
}

check_zsh() {
    if [[ "$-" != *i* || -z "$PS1" ]]; then
        # don't check on non-interactive shells
        return
    fi

    BIN_ZSH="$(which zsh 2>/dev/null)"
    version_compare "$("$BIN_ZSH" --version | awk '{print $2}')" "$minimum_zsh_version"
    case "$?" in
        0|1)
            export SHELL="$BIN_ZSH"
            exec "$SHELL" ${-+-$-}
            ;;
        2)
            if [[ -x "$HOME/.local/bin/zsh" ]]; then
                BIN_ZSH="$HOME/.local/bin/zsh"
                version_compare "$("$BIN_ZSH" --version | awk '{print $2}')" "$minimum_zsh_version"
                case "$?" in
                    0|1)
                        export SHELL="$BIN_ZSH"
                        exec "$SHELL" ${-+-$-}
                        ;;
                esac
            fi

            if [[ -z "$zsh_already_built" ]]; then
                if curl --help >/dev/null; then
                    if build_zsh; then
                        zsh_already_built=1
                        # re-enter, and the fresh zsh should work
                        . "$HOME/.zsh/ensure.sh"
                    fi
                fi
            fi
            ;;
    esac
}

case "$PATH" in
    *"$HOME/.local/bin"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH"
esac

if [[ -n "$ZSH_VERSION" ]]; then
    version_compare "$ZSH_VERSION" "$minimum_zsh_version"
    case "$?" in
        0|1)
            # done
            ;;
        2)
            check_zsh
            ;;
    esac
else
    check_zsh
fi
