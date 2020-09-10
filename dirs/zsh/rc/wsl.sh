if [[ "$OSTYPE" = "linux-gnu" && -n "$WSL_DISTRO_NAME" ]] && type wslview &>/dev/null; then
    if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop && "$(head -n1  /proc/sys/fs/binfmt_misc/WSLInterop)" == "enabled" ]]; then
        alias open=xdg-open

        hash -d profile="$(wslpath "$(wslvar -s USERPROFILE)")"
        if [[ ! -e "$HOME/profile" ]]; then
            ln -s ~profile "$HOME/profile"
        fi

        # if interactive login shell starting on home directory
        if [[ $- = *l* && $- = *i* && $PWD = ~profile ]]; then
            # cd to the wsl home directory
            #cd
        fi
    fi
fi
