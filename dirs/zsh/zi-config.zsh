zi ice depth=1 nocd if='[[ $THEME = p10k && ( ${TERM##*-} = 256color || ${terminfo[colors]:?} -ge 256 ) ]]'
zi light romkatv/powerlevel10k

zi ice as"command" from"gh-r" \
  atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
  atpull"%atclone" src"init.zsh" \
  if='[[ $THEME = starship && ( ${TERM##*-} = 256color || ${terminfo[colors]:?} -ge 256 ) ]]'
zi light starship/starship

# load earliest (but after p10k) to avoid it clobbering things set by other plugins
COMPLETION_WAITING_DOTS=true
zi ice depth='1' as'null' nocd \
  atinit='HISTFILE="$HOME/.zsh/history"; HIST_STAMPS="yyyy-mm-dd"' \
  multisrc='lib/{key-bindings,compfix,functions,history,termsupport}.zsh' \
  atload='![[ "${(%):-%#}" != "#" ]] && handle_completion_insecurities'
zi load robbyrussell/oh-my-zsh

zi ice as='completion' \
  atclone="chmod +x ./rustup-init.sh && ./rustup-init.sh -v -y --no-modify-path --default-toolchain none && ${(q)USERPROFILE:-$HOME}/.cargo/bin/rustup completions zsh > ./_rustup" \
  atpull='%atclone' \
  atload='if [[ -f "$HOME/.cargo/env" ]]; then source "$HOME/.cargo/env"; fi'
zi snippet 'https://static.rust-lang.org/rustup/rustup-init.sh'

zi ice lucid atclone='"${commands[dircolors]:-$commands[gdircolors]}" -b LS_COLORS > clrs.zsh' \
    atpull='%atclone' pick='clrs.zsh' nocompile'!' \
    atload='zstyle '\'':completion:*'\'' list-colors "${(s.:.)LS_COLORS%:}"' \
    if='[[ -n "${commands[dircolors]:-$commands[gdircolors]}" ]]'
#zi light trapd00r/LS_COLORS
zi light arcticicestudio/nord-dircolors

zi ice lucid wait blockf atpull='zi creinstall -q .'
zi light zsh-users/zsh-completions

zi ice as='completion' mv='_mpv.zsh -> _mpv'
zi snippet 'https://github.com/mpv-player/mpv/blob/master/etc/_mpv.zsh'

if [[ "${(%):-%#}" != "#" ]]; then
    # only if not root
    zstyle :omz:plugins:ssh-agent agent-forwarding on
    [[ -e "$HOME/.ssh/id_ed25519" ]] && zstyle :omz:plugins:ssh-agent identities id_ed25519
    zi ice silent
    zi snippet OMZ::plugins/ssh-agent/ssh-agent.plugin.zsh
fi

if [[ -e "$HOME/.homesick/repos/homeshick/completions/_homeshick" ]]; then
    zi ice lucid as='completion'
    zi snippet "$HOME/.homesick/repos/homeshick/completions/_homeshick"
fi

zi ice lucid wait atload='_zsh_autosuggest_start'
zi light zsh-users/zsh-autosuggestions

# must be last
function .zicompinit () {
    zicompinit
    zrecompile -q -p -M "$_comp_dumpfile"
}
zi ice lucid wait \
    atinit='ZI[COMPINIT_OPTS]=-i; ZI[ZCOMPDUMP_PATH]="${ZDOTDIR:-$HOME}/.zsh/.${SHORT_HOST:-$HOST}-${ZSH_VERSION}.zcompdump"; .zicompinit; zpcdreplay; unset -f .zicompinit'
zi light z-shell/F-Sy-H

zstyle ":history-search-multi-word" page-size "11"
zi ice wait lucid
zi light z-shell/H-S-MW
