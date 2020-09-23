# NOTE: this file is also being sourced by bash scripts

if grep -q '^ID.*=.*ubuntu' /etc/os-release 2>/dev/null; then
  skip_global_compinit=1
fi

if [[ -f /usr/sbin/start-systemd-namespace ]]; then
  if [[ -n "$ZSH_EXECUTION_STRING" ]]; then
    # start-systemd-namespace expects to see bash-specific envvars
    BASH_EXECUTION_STRING="$ZSH_EXECUTION_STRING"
  fi
  . /usr/sbin/start-systemd-namespace
fi

if [[ -z "${PROFILEREAD+true}" ]]; then
  # Skip the Ubuntu global compinit
  readonly skip_global_compinit=1
  # Skip Cygwin's global initialization
  # also used to avoid multiple initialization
  readonly PROFILEREAD=true

  export LC_ALL=en_US.UTF-8
  export LANG=$LC_ALL

  if [[ "$OSTYPE" = "cygwin" ]]; then
    # replicate, where reasonable, the contents of cygwin's /etc/profile
    # we got here because the PROFILEREAD that it's supposed to set... wasn't

    # setting CYGWIN_USEWINPATH non-empty in the system variables
    # assumes that you've already set up PATH so that Cygwin works
    # correctly -- no further alteration is done
    if [[ -z "${CYGWIN_USEWINPATH}" ]]; then
      # setting CYGWIN_NOWINPATH non-empty in the system variables
      # prevents use of the existing PATH and a clean PATH just for
      # Cygwin is set up -- you need to add any extra path components
      # you need in your personal startup files
      if [[ "${CYGWIN_NOWINPATH-addwinpath}" != "addwinpath" ]]; then
        unset PATH
      fi
    fi
    # NOTE: since we are skipping Cygwin's global initialization
    # we need to add all PATH elements in here; there are no defaults
    # other than what we inherit from Vindows
    export PATH="/usr/bin:/usr/sbin:/bin:/sbin${PATH:+:${PATH}}"

    # see https://cygwin.com/ml/cygwin/2014-05/msg00352.html
    # MANPATH="/usr/local/man:/usr/share/man:/usr/man${MANPATH:+:${MANPATH}}"
    export INFOPATH="/usr/local/info:/usr/share/info:/usr/info${INFOPATH:+:${INFOPATH}}"

    # Set the user id
    export USER="$(/usr/bin/id -un)"

    # TMP and TEMP as defined in the Windows environment
    # can have unexpected consequences for cygwin apps, so we define
    # our own to match GNU/Linux behaviour.
    export TMP="/tmp"
    export TEMP="/tmp"

    if [[ -e '/proc/registry/HKEY_CURRENT_USER/Software/Microsoft/Windows NT/CurrentVersion/Windows/Device' ]]; then
      read -r PRINTER < '/proc/registry/HKEY_CURRENT_USER/Software/Microsoft/Windows NT/CurrentVersion/Windows/Device'
      PRINTER=${PRINTER%%,*}
    fi

    # Default to removing the write permission for group and other
    #  (files normally created with mode 777 become 755; files created with
    #  mode 666 become 644)
    umask 022

    # the handling of HOME is not relevant if we get this far
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

  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:${PATH:+:${PATH}}"

  if [[ "$OSTYPE" = "cygwin" ]]; then
    export PATH="$HOME/.local/cygwin/bin${PATH:+:${PATH}}"
  elif [[ -n "$WSL_DISTRO_NAME" && -f /proc/sys/fs/binfmt_misc/WSLInterop && \
    "$(head -n1 /proc/sys/fs/binfmt_misc/WSLInterop)" == "enabled" ]]; then
    export PATH="$HOME/.local/wsl/bin${PATH:+:${PATH}}"
  fi
fi

if [[ "$OSTYPE" = "cygwin" ]]; then
  export EXECIGNORE="*.dll${EXECIGNORE:+:${EXECIGNORE}}"

  if [[ -n "$ZSH_VERSION" ]]; then
    fignore+=(.dll .DLL)
  fi
  if [[ -n "$BASH_VERSION" ]]; then
    shopt -s completion_strip_exe
  fi
fi
