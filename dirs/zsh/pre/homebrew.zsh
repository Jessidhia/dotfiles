if type brew &>/dev/null && [[ -n "$(brew --prefix)" ]]; then
  eval "$(brew shellenv)"
fi
