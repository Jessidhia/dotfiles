if [[ -z $commands[moar] && -n $commands[go] ]] &&
  is-at-least 1.9.0 "$(go version | cut -d' ' -f3 | sed s/go//)"; then
  ! go get -v github.com/walles/moar
  hash -r
fi

local p
for p in moar most less; do
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
fi
