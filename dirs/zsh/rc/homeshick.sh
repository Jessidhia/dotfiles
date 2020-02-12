if [[ -e "$HOME/.homesick/repos/homeshick/homeshick.sh" ]]; then
  . "$HOME/.homesick/repos/homeshick/homeshick.sh"
fi

hash -d dotfiles="$HOME"/.homesick/repos/dotfiles
