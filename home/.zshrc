. "$HOME/.zsh/ensure.sh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

for rc in $HOME/.zsh/pre/*.(|z)sh; do . "$rc"; done

. "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi; (( ${+_comps} )) && _comps[zi]=_zi
if [[ -f "${ZI[ZMODULES_DIR]}/zpmod/Src/zi/zpmod.so" ]]; then
  module_path+=( "${ZI[ZMODULES_DIR]}/zpmod/Src" )
  zmodload zi/zpmod &>/dev/null
fi

. "$HOME/.zsh/zi-config.zsh"

for rc in $HOME/.zsh/rc/*.(|z)sh; do . "$rc"; done

if [[ "$do_burst" = true ]]; then
    unset do_burst
    @zi-scheduler burst || true
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g PS2="%F{$POWERLEVEL9K_BACKGROUND}${(g::)POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL}%f%K{$POWERLEVEL9K_BACKGROUND}%F{255} %_ %k%F{$POWERLEVEL9K_BACKGROUND}${(g::)POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL}%f "
typeset -g PS3="%F{$POWERLEVEL9K_BACKGROUND}${(g::)POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL}%f "

autoload -U zrecompile
function .zrecompile () {
  # if filtering the parameter list by the ones that match "#-(|*)p" has a non-empty result
  if [[ -n ${(M@)"${@:-}":##-(|*)p} ]]; then
    # then don't do the default paths; paths were passed with -p
    \zrecompile "$@"
  else
    # prepends "--" "-U" "-R" to everything matched by the glob
    \zrecompile "$@" -p \
      "${ZDOTDIR:-$HOME}"/.(zshrc|zshenv|*.(|z)sh)(P:--:P:-U:P:-R:) \
      "${ZDOTDIR:-$HOME}"/.zsh/{,(pre|rc)/}*.(|z)sh(P:--:P:-U:P:-R:)

    if [[ "$OSTYPE" != cygwin ]]; then
      local p
      # for all paths in fpath where the parent directory is writable to
      for p in ${^fpath}(NFe.'[[ -w $REPLY:h ]]'.); do
        if [[ -d $p ]]; then
          \zrecompile "$@" -p -U -R $p $p/*
        else
          \zrecompile "$@" -p -U -R $p
        fi
      done
    fi
  fi
}
alias zrecompile=.zrecompile

zrecompile -q
