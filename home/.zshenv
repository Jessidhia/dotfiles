# NOTE: this file is also being sourced by bash scripts

if grep -q '^ID.*=.*ubuntu' /etc/os-release; then
  skip_global_compinit=1
fi

if [[ -f /usr/sbin/start-systemd-namespace ]]; then
  if [[ -n "$ZSH_EXECUTION_STRING" ]]; then
    # start-systemd-namespace expects to see bash-specific envvars
    BASH_EXECUTION_STRING="$ZSH_EXECUTION_STRING"
  fi
  . /usr/sbin/start-systemd-namespace
fi

if [[ -z "$PROFILEREAD" ]]; then
  # Skip the Ubuntu global compinit
  readonly skip_global_compinit=1
  # Skip Cygwin's global initialization
  # #lso used to avoid multiple initialization
  readonly PROFILEREAD=1

  export LC_ALL=en_US.UTF-8
  export LANG=$LC_ALL

  if [[ "$OSTYPE" = "cygwin" ]]; then
    if [[ -n "${CYGWIN_NOWINPATH}" ]]; then
      unset PATH
    fi
    # NOTE: since we are skipping Cygwin's global initialization
    # we need to add all PATH elements in here; there are no defaults
    # other than what we inherit from Vindows
    export PATH="/usr/bin:/usr/sbin:/bin:/sbin${PATH:+:${PATH}}"
  fi

  if [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin${PATH:+:${PATH}}"
  fi

  if [[ -d "/usr/local/go/bin" ]]; then
    export PATH="/usr/local/go/bin${PATH:+:${PATH}}"
  fi
  # homebrew's GOROOT/bin
  if [[ -d "/usr/local/opt/go/libexec/bin" ]]; then
    export PATH="/usr/local/opt/go/libexec/bin${PATH:+:${PATH}}"
  fi

  export PATH="$HOME/.local/bin${PATH:+:${PATH}}"

  if [[ "$OSTYPE" = "cygwin" ]]; then
    export PATH="$HOME/.local/cygwin/bin${PATH:+:${PATH}}"
  elif [[ -n "$WSL_DISTRO_NAME" && -f /proc/sys/fs/binfmt_misc/WSLInterop && \
    "$(head -n1 /proc/sys/fs/binfmt_misc/WSLInterop)" == "enabled" ]]; then
    export PATH="$HOME/.local/wsl/bin${PATH:+:${PATH}}"
  fi
fi
