#!/usr/bin/env zsh

if [[ -n $commands[src-hilite-lesspipe.sh] ]]; then
  if src-hilite-lesspipe.sh "$@" 2>/dev/null; then
    exit 0
  fi
fi

exit 1
