export LESS="-gimQRuw"

alias less="less -JN"

# if [[ -z $commands[moar] && -n $commands[go] ]] &&
#   is-at-least 1.9.0 "$(go version | cut -d' ' -f3 | sed s/go//)"; then
#   ! go get -v github.com/walles/moar
#   hash -r
# fi

local p
for p in most moar less; do
  : ${PAGER:=$commands[$p]}
done
unset p

if [[ -z "$PAGER" ]]; then
  unset PAGER
else
  if [[ $PAGER != *less ]]; then
    alias less="$PAGER"
  fi
  export PAGER

  if [[ $PAGER = *(less|most) ]]; then
    export MANPAGER="$PAGER -s"
  fi

  if [[ -n $commands[moar] ]]; then
    export GIT_PAGER=$commands[moar]
  fi
fi

# patch zinit's pager to avoid the possible `less` alias above
function .zinit-pager () {
  if [[ ${${commands[less]}:A:t} = 'busybox' ]]; then
    more
  else
    command less -FRXi
  fi
}
