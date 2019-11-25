# work around mosh bug -- for some reason, it (unconditionally?) sets TERM to xterm-256color
# this assumes one is always SSHing from inside a screen/tmux session!

if [[ "$TERM" = "xterm-256color" && "$OSTYPE" != "darwin"* && "$OSTYPE" != "cygwin" ]]; then
    parent="$(ps -o command -p "$(ps -o ppid -p $$ | tail -1)" 2>&1 | tail -1 | cut -d' ' -f1)"

    if [[ "$parent" = "mosh-server" ]]; then
        export TERM=screen-256color
    fi
fi

