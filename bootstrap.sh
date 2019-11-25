#!/bin/sh

# bootstrap script to install Homeshick and preferred castles to a new system.
# Modified from the script in https://github.com/andsens/homeshick/wiki/Simplistic-bootstraping-script

tmpdir="${TMPDIR}"
if [ -z "$tmpdir" ]; then
  tmpdir="${TEMP:-/tmp/}"
fi
tmpfilename="${tmpdir%/}/${0##*/}.XXXXX"

if type mktemp >/dev/null; then
  tmpfile="$(mktemp "${tmpfilename}")"
else
  tmpfile="$(echo "${tmpfilename}" | sed "s/X\{5\}$/${RANDOM:-XXXXX}/")"
fi

trap 'rm -f "$tmpfile"' EXIT

cat <<'EOF' > "$tmpfile"
# Which Homeshick castles do you want to install?
#
# Each line is passed as the argument(s) to `homeshick clone`.
# Lines starting with '#' will be ignored.
#
# If you remove or comment a line that castle will NOT be installed.
# However, if you remove or comment everything, the script will be aborted.

# Plugin management
# tmux-plugins/tpm

# Main castles
Jessidhia/dotfiles

# Private castles (commented by default)
# secret@example.org:securerc.git
EOF

editor="${VISUAL}"
if [ -z "$editor" ]; then
  if type code >/dev/null; then
    editor="code -w"
  else
    editor="${EDITOR:-nano}"
    if ! type "$editor" >/dev/null; then
      editor=vi
    fi
  fi
fi

${editor} $tmpfile

code=$?

if [ "$code" -ne 0 ]; then
  echo "Editor returned ${code}." 1>&2
  exit 1
fi

castles=""

while read line; do
  castle=$(echo "$line" | sed '/^[ \t]*#/d;s/^[ \t]*\(.*\)[ \t]*$/\1/')
  if [ -n "$castle" ]; then
    castles="$castles"$'\n'"$castle"
  fi
done <"$tmpfile"

if [ "${#castles}" -eq 0 ]; then
  echo "No castles to install. Aborting."
  exit 0
fi

if [ ! -f "$HOME"/.homesick/repos/homeshick/homeshick.sh ]; then
  git clone https://github.com/andsens/homeshick "$HOME"/.homesick/repos/homeshick
fi

. "$HOME"/.homesick/repos/homeshick/homeshick.sh

while read castle; do
  if [[ -n "$castle" ]]; then
    if [[ -d "$HOME"/.homesick/repos/"${castle##*/}" ]]; then
      homeshick pull --batch "${castle##*/}"
    else
      homeshick clone --batch "$castle"
    fi
  fi
done <<EOF
$castles
EOF
