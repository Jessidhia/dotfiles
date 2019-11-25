if [[ -x "$HOME/.nodenv/bin/nodenv" ]]; then
    export PATH="$HOME/.nodenv/bin:$PATH"
fi

which nodenv &>/dev/null && eval "$(nodenv init -)"
