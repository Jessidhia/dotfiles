
if ls --color &>/dev/null; then
    alias ls='ls -hF --color=auto' # GNU ls
else
    alias ls='ls -hFG' # BSD ls
fi
