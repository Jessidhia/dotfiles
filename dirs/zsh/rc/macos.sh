if [[ "$OSTYPE" = darwin* ]]; then
    if [[ -d /usr/local/opt/python3/libexec/bin ]]; then
        export PATH="/usr/local/opt/python3/libexec/bin:$PATH"
    fi
    export PKG_CONFIG_LIBDIR="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig/:/opt/X11/lib/pkgconfig:/usr/lib/pkgconfig"
    export PKG_CONFIG_PATH="/usr/local/opt/expat/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig"
    #export SSL_CERT_FILE="/usr/local/etc/openssl/ca-bundle.crt"

    if [[ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
        export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    fi

    if type brew &>/dev/null && [[ -n "$(brew --prefix)" ]]; then
        if [[ -d "$(brew --prefix)/share/google-cloud-sdk" ]]; then
            source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
            source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
        fi
    fi

    if [[ -d "$HOME"/.homesick/repos/dotfiles ]]; then
        # manually install files from dirs/Library
        # homeshick can't manage them well, at least not without polutting non-macos homes
        local Library="$HOME"/.homesick/repos/dotfiles/dirs/Library
        .library_install() {
            local folder_name="$1"

            install -d "$HOME"/Library/"$folder_name"
            pushd "$HOME"/Library/"$folder_name" &>/dev/null
            ln -s ../../.homesick/repos/dotfiles/dirs/Library/"$folder_name"/* "$HOME"/Library/"$folder_name"/ &>/dev/null
            popd &>/dev/null
        }

        .library_install KeyBindings

        unset Library
        unset -f .library_install
    fi
fi
