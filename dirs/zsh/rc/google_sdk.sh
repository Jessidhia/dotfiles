if [[ -d "${HOME}/.local/google-cloud-sdk" ]]; then
  source "${HOME}/.local/google-cloud-sdk/path.zsh.inc"
  source "${HOME}/.local/google-cloud-sdk/completion.zsh.inc"
elif type brew &>/dev/null && [[ -n "$(brew --prefix)" ]]; then
  local brew_prefix="$(brew --prefix)"
  if [[ -d "$brew_prefix/share/google-cloud-sdk" ]]; then
    source "$brew_prefix/share/google-cloud-sdk/path.zsh.inc"
    source "$brew_prefix/share/google-cloud-sdk/completion.zsh.inc"
  fi
  unset brew_prefix
fi
