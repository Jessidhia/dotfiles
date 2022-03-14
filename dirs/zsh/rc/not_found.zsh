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

  local skip_echo

  if [[ -x /usr/libexec/pk-command-not-found ]]; then
    # ported from /etc/profile.d/PackageKit.sh, since we're overriding it
    if [[ $- == *"i"* ]] &&
        [[ -S /run/dbus/system_bus_socket ]] &&
        [[ -x /usr/libexec/packagekitd ]] &&
        # this is a bash-completion check; does it work on zsh?
        [[ -z ${COMP_CWORD-} ]]; then

       # pk-command-not-found already prints a bash-style "command-not-found" message
       skip_echo=1

       /usr/libexec/pk-command-not-found "$@"
       local ret=$?
       # if pk handled it and it's no longer "not found"
       if [[ $ret != 127 ]]; then
          return $ret
       fi
    fi
  fi

  # only if the command includes a @ somewhere (e.g. foo@latest)
  if [[ -n $commands[npx] ]] && [[ $1 = *@* ]]; then
    npx -- "$@"
    return $?
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
  [[ -z $skip_echo ]] && is-at-least 5.3 && echo "zsh: command not found: $1" >&2

  return 127
}
