. "$HOME/.zsh/ensure.sh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

for rc in $HOME/.zsh/pre/*; do . "$rc"; done

. "$HOME/.zplugin/bin/zplugin.zsh"
. "$HOME/.zsh/zplugin-config.zsh"

for rc in $HOME/.zsh/rc/*; do . "$rc"; done

if test -e "${HOME}/.iterm2_shell_integration.zsh"; then . "${HOME}/.iterm2_shell_integration.zsh"; fi

if [[ "$do_burst" = true ]]; then
    unset do_burst
    -zplg-scheduler burst || true
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g PS2="%F{$POWERLEVEL9K_BACKGROUND}${(g::)POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL}%f%K{$POWERLEVEL9K_BACKGROUND}%F{255} %_ %k%F{$POWERLEVEL9K_BACKGROUND}${(g::)POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL}%f "
typeset -g PS3="%F{$POWERLEVEL9K_BACKGROUND}${(g::)POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL}%f "
