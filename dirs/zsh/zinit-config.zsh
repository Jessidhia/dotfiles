zinit ice depth=1 nocd
zinit light romkatv/powerlevel10k

# load earliest (but after p10k) to avoid it clobbering things set by other plugins
COMPLETION_WAITING_DOTS=true
zinit ice depth='1' as'null' nocd \
    atinit='HISTFILE="$HOME/.zsh/history"; HIST_STAMPS="yyyy-mm-dd"' \
    multisrc='lib/{key-bindings,compfix,functions,history,termsupport}.zsh' \
    atload='![[ "${(%):-%#}" != "#" ]] && handle_completion_insecurities'
zinit load robbyrussell/oh-my-zsh

zinit ice as='completion' \
  atclone="chmod +x ./rustup-init.sh && ./rustup-init.sh -v -y --default-toolchain none && ${(q)USERPROFILE:-$HOME}/.cargo/bin/rustup completions zsh > ./_rustup" \
  atpull='%atclone' \
  atload='if [[ -f "$HOME/.cargo/env" ]]; then source "$HOME/.cargo/env"; fi'
zinit snippet 'https://github.com/rust-lang/rustup/blob/master/rustup-init.sh'

zinit ice lucid atclone='"${commands[dircolors]:-$commands[gdircolors]}" -b LS_COLORS > clrs.zsh' \
    atpull='%atclone' pick='clrs.zsh' nocompile'!' \
    atload='zstyle '\'':completion:*'\'' list-colors "${(s.:.)LS_COLORS%:}"' \
    if='[[ -n "${commands[dircolors]:-$commands[gdircolors]}" ]]'
zinit light trapd00r/LS_COLORS

zinit ice lucid wait blockf atpull='zinit creinstall -q .'
zinit light zsh-users/zsh-completions

zinit ice as='completion' mv='_mpv.zsh -> _mpv'
zinit snippet 'https://github.com/mpv-player/mpv/blob/master/etc/_mpv.zsh'

if [[ "${(%):-%#}" != "#" ]]; then
    # only if not root
    zstyle :omz:plugins:ssh-agent agent-forwarding on
    [[ -e "$HOME/.ssh/id_ed25519" ]] && zstyle :omz:plugins:ssh-agent identities id_ed25519
    zinit ice silent
    zinit snippet OMZ::plugins/ssh-agent/ssh-agent.plugin.zsh
fi

if [[ -e "$HOME/.homesick/repos/homeshick/completions/_homeshick" ]]; then
    zinit ice lucid as='completion'
    zinit snippet "$HOME/.homesick/repos/homeshick/completions/_homeshick"
fi

zinit ice lucid wait atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# must be last
function .zicompinit () {
    zicompinit
    zrecompile -q -p -M "$_comp_dumpfile"
}
zinit ice lucid wait \
    atinit='ZINIT[COMPINIT_OPTS]=-i; ZINIT[ZCOMPDUMP_PATH]="${ZDOTDIR:-$HOME}/.zsh/.${SHORT_HOST:-$HOST}-${ZSH_VERSION}.zcompdump"; .zicompinit; zpcdreplay; unset -f .zicompinit'
zinit light z-shell/fast-syntax-highlighting
