export POWERLINE="$HOME/.vim/bundle/powerline"

export PATH="$POWERLINE/scripts:$PATH"
export PYTHONPATH="$POWERLINE:$PYTHONPATH"

if powerline -h &>/dev/null; then
    powerline_test="$(powerline shell left 2>/dev/null)"
    if [[ "$?" = 0 && -n "$powerline_test" ]]; then
        unset ZSH_THEME
    else
        # Prevent the post-"oh-my-zsh"-init script from sourcing powerline.zsh
        unset POWERLINE
    fi
fi
