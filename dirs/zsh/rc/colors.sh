autoload -U colors && colors

if [[ "${terminfo[colors]}" -ge 16 ]]; then
    # enable color output on BSD tools
    export CLICOLOR=true
fi

if [[ ! "$COLORTERM" =~ (24bit|truecolor) && "${terminfo[colors]}" -lt 16777216 && "${terminfo[colors]}" -ge 88 ]]; then
    # if the terminal doesn't support RGB colors, load zsh's color approximation module (which requires at least 88 color support)
    zmodload zsh/nearcolor
fi

# hardcoded preset from oh-my-zsh's theme-and-appearance.zsh
export LSCOLORS="Gxfxcxdxbxegedabagacad"

if exa --git-ignore -d . &>/dev/null; then
    alias ls='exa --icons --color-scale --group-directories-first -Fgh'
    alias tree='ls -T'
    alias lsg='ls --git --git-ignore'
elif lsd --icon-theme=fancy -d . &>/dev/null; then
    alias ls='lsd -F'
    # problem: lsd has no way to limit depth!
    alias tree='ls --tree'
else
    # stolen from oh-my-zsh's theme-and-appearance.zsh but heavily simplified
    # only used if neither exa or lsd are available
    if [[ "$OSTYPE" =~ (darwin|freebsd) ]]; then
        ls -G . &>/dev/null && alias ls='ls -hFG'

        # uses GNU ls if installed, ignores otherwise
        [[ -n "$LS_COLORS" ]] && gls --color -d . &>/dev/null && alias ls='gls --color=tty -hF'
    else
        ls --color -d . &>/dev/null && alias ls='ls --color=tty -hF' || { ls -G . &>/dev/null && alias ls='ls -hFG' }
    fi
fi
