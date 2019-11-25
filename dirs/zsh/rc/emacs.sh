#! /usr/bin/env zsh

function emacs () {
  case "$1" in
    --daemon)
      command emacs -nw "$@"
      return
      ;;
    --kill|-k)
      command emacsclient -e "(kill-emacs)"
      return
      ;;
  esac

  case "$2" in
    --kill|-k)
      command emacsclient -e "(kill-emacs)"
      return
    ;;
  esac

  command emacsclient -a "" -nw "$@"
}

alias emacs='emacs -nw'
