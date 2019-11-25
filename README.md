Managed with [homeshick](https://github.com/andsens/homeshick)

## WARNING

- This castle includes a `.bash_login` script which will replace
  interactive bash sessions with a zsh session (to deal with a lack of
  `chsh -s` access).
- `zsh` 5.7.0 or newer is required. If one is not available, the login
  script will attempt to compile one and install it on `$HOME/.local`.

## Installation

### If `homesick` or `homeshick` are already available

Add `Jessidhia/dotfiles` as a castle.

```sh
homeshick clone Jessidhia/dotfiles
```

### If `homeshick` is not available

You can run the [bootstrap.sh](https://github.com/Jessidhia/dotfiles/blob/master/bootstrap.sh) script from a shell.

```sh
curl https://raw.githubusercontent.com/Jessidhia/dotfiles/master/bootstrap.sh | bash -
```

The script should run with any bourne shell but `homeshick`, which it installs,
requires `bash` to be available under `/bin/bash`.
