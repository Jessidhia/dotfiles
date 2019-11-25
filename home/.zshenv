# NOTE: this file is also being sourced by bash scripts

# Skip the Ubuntu global compinit
skip_global_compinit=1

export LC_ALL=en_US.UTF-8
export LANG=$LC_ALL

if [[ "$OSTYPE" = "darwin"* && -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

if [[ "$OSTYPE" = "cygwin" ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
fi

[[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"
# homebrew's GOROOT/bin
[[ -d "/usr/local/opt/go/libexec/bin" ]] && export PATH="/usr/local/opt/go/libexec/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

if [[ "$OSTYPE" = "cygwin" ]]; then
    export PATH="$HOME/.local/cygwin/bin:$PATH"
fi
