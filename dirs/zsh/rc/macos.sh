if [[ "$OSTYPE" = darwin* ]]; then
    export PKG_CONFIG_LIBDIR="/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig:/usr/lib/pkgconfig"
    #export SSL_CERT_FILE="/usr/local/etc/openssl/ca-bundle.crt"

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
