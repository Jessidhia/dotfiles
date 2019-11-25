if [[ -x "$HOME/.rbenv/bin/rbenv" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
fi

which rbenv &>/dev/null && eval "$(rbenv init -)"
