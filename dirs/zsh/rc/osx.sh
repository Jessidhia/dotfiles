if [[ "$OSTYPE" = darwin* ]]; then
    export PKG_CONFIG_LIBDIR="/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig:/usr/lib/pkgconfig"
#    export SSL_CERT_FILE="/usr/local/etc/openssl/ca-bundle.crt"

    # hardcode a path for quick checking -- "brew command" has to boot up ruby and that takes _forever_
    if [[ -x /usr/local/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/cmd/brew-which-formula.rb ]] ||
        brew command which-formula &>/dev/null
    then
        # ported to better zsh from the output of `echo "$(brew command-not-found-init)"`
        function +handle_homebrew_command_not_found () {
            builtin emulate -L zsh
            local cmd="$1"

            # The code below is based off this Linux Journal article:
            #   http://www.linuxjournal.com/content/bash-command-not-found

            # do not run when inside Midnight Commander or within a Pipe; but always run on CI
            if [[ -z "$CI" && ( -n "$MC_SID" || ! -t 1 ) ]] ; then
                # Zsh skips printing this on >=5.3
                is-at-least 5.3 && echo "zsh: command not found: $cmd" >&2
                return 127
            fi

            print -Pn '%1F. . . . .%f\r'
            # TODO: just parse homebrew-command-not-found/executables.txt instead, `brew which-formula` is really slow
            local txt="$(brew which-formula --explain "$cmd" 2>/dev/null)"

            if [[ -n "$txt" ]]; then
                echo "$txt"
            else
                # Zsh skips printing this on >=5.3
                is-at-least 5.3 && echo "zsh: command not found: $cmd" >&2
            fi

            return 127
        }

        function command_not_found_handler () {
            +handle_homebrew_command_not_found "$@"
            return $?
        }
    fi
fi
