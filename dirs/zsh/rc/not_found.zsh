# based on the outputs of:
# `echo "$(brew command-not-found-init)"`
# `npx --shell-auto-fallback zsh`

function command_not_found_handler () {
  builtin emulate -L zsh

  # The code below is based off this Linux Journal article:
  #   http://www.linuxjournal.com/content/bash-command-not-found

  # do not run when inside Midnight Commander or within a Pipe; but always run on CI
  if [[ -z "$CI" && ( -n "$MC_SID" || ! -t 1 ) ]] ; then
      # Zsh skips printing this on >=5.3
      is-at-least 5.3 && echo "zsh: command not found: $1" >&2
      return 127
  fi

  print -Pn '%1F. . . . .%f\r'

  if [[ -n $commands[npx] ]]; then
    if [[ $1 != *@* ]]; then
      # hmm... this is kinda the same as having node_modules/.bin at the end of $PATH, but fancier?
      npx --no-install --quiet -- "$@"
      local ret=$?

      if [[ $ret != 127 ]]; then
        # assume that only npx gets to return 127 (if package not already installed)
        return $ret
      fi
    else
      npx -- "$@"
      return $?
    fi
  fi

  # TODO: just parse homebrew-command-not-found/executables.txt instead, `brew which-formula` is really slow
  if [[ -n $commands[brew] ]]; then
    local txt="$(brew which-formula --explain "$1" 2>/dev/null)"

    if [[ -n "$txt" ]]; then
      echo "$txt"
      return 127
    fi
  fi

  # Zsh skips printing this on >=5.3
  is-at-least 5.3 && echo "zsh: command not found: $1" >&2

  return 127
}
