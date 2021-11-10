export TD_TMP="${XDG_STATE_HOME:-${HOME}/.local/state}/tradedangerous"
export TD_DATA="${XDG_DATA_HOME:-${HOME}/.local/share}/tradedangerous"
export FDEVJRNDIR="${HOME}/profile/Saved Games/Frontier Developments/Elite Dangerous"

### Adapted from https://github.com/eyeonus/Trade-Dangerous/blob/master/scripts/

# You can only have one set of variables "live" at a time, comment out
# old ships while you are not flying them, then you can just uncomment
# them later on.

# leave empty for "auto" (current ship pad size)
export TD_CAP=
export TD_EMPTYLY=
export TD_LADENLY=
# usable pad sizes (SML)
export TD_PADS=

# After a given number of hops, discard candidates that have scored less
# than the given percentage of the best candidate.
export TD_PRUNE_HOPS=2   # only after N hops
export TD_PRUNE_SCORE=20 # percentage

# Maximum number of jumps between hops
export TD_JUMPS=4

# additional default arguments to give to tdrun
export TD_RUN_ARGS=(
  -vv
  --color
  --progress
  --fc=N
  --avoid=slaves,tobacco
  --age=30
  --lsp=20
  --ls-max 100000

)

# opens this file in vscode
tdedit() {
  local self=${ZSH_HOME:-${HOME}/.zsh}/rc/tradedangerous.sh
  code -w "$self"
  echo 'Reloading tradedangerous.sh'
  . "$self"
}

# scripts from the git repository ported to functions

tdbuyfrom() {
  # Usage: tdbuyfrom [<station>] <item> [... trade.py options]
  #
  # Finds stations near <station> that are selling <item>

  local near="$1"
  shift 2>/dev/null
  local prod="$1"
  shift 2>/dev/null
  local extra=()
  if [[ -n $near && (-z $prod || $prod == -*) ]]; then
    # assume station was elided
    extra=($prod)
    prod="$near"
    near="$(.td_tool --station)"
    echo "NOTE: using ${near} as the origin"
  fi

  if [[ -z \
    $near || $near == -* || -z \
    $prod || $prod == -* ]]; then
    echo "ERROR: Usage: $0 [<station>] <item> ..."
    return 1
  fi

  local cmd=(trade buy -vv -p \"$(.td_tool --stat pad_size)\" --near \"$near\" \"$prod\" $extra $@)
  echo \$ $cmd
  eval "$cmd"
}

tdsellto() {
  # Usage: tdsellto [<station>] <item> [... trade.py options]
  #
  # Finds stations near <station> that are buying <item>

  local near="$1"
  shift 2>/dev/null
  local prod="$1"
  shift 2>/dev/null
  local extra=()
  if [[ -n $near && (-z $prod || $prod == -*) ]]; then
    # assume station was elided
    extra=($prod)
    prod="$near"
    near="$(.td_tool --station)"
    echo "NOTE: using ${near} as the origin"
  fi

  if [[ -z \
    $near || $near == -* || -z \
    $prod || $prod == -* ]]; then
    echo "ERROR: Usage: $0 [<station>] <item> ..."
    return 1
  fi

  local cmd=(trade sell -vv -p \"$(.td_tool --stat pad_size)\" --near \"$near\" \"$prod\" $extra $@)
  echo \$ $cmd
  eval "$cmd"
}

tdloc() {
  # Usage: tdloc [<place>] <maxly> [... trade.py options]
  #
  # Finds systems and their stations local to <place>
  # that are within <ly> range.

  local place=$1
  shift 2>/dev/null
  local ly=$1
  shift 2>/dev/null

  if [[ -n $place && (-z $ly || $ly == -*) ]]; then
    # assume station was elided
    ly="$place"
    place="$(.td_tool --station)"
    echo "NOTE: using ${place} as the place"
  fi

  if [[ -z $place || $place == -* || -z $ly || $ly == -* ]]; then
    echo "ERROR: Usage: $0 [<place>] <ly> ..."
    return 1
  fi

  local cmd="trade local \"$place\" --ly \"$ly\" $*"
  echo \$ $cmd
  eval "$cmd"
}

tdnav() {
  # Usage: tdnav [<from>] <to> [... trade.py options]
  #
  # Finds a route from one place to another.

  local from=$1
  shift 2>/dev/null
  local to=$1
  shift 2>/dev/null

  if [[ -n $from && (-z $to || $to == -*) ]]; then
    # assume "from" was elided
    to="$from"
    from="$(.td_tool --station)"
    echo "NOTE: using ${from} as the origin"
  fi

  local cmd="trade nav --ly ${TD_EMPTYLY:-$(.td_tool --stat unladen_ly)} \"$from\" \"$to\" $@"
  echo \$ $cmd
  eval "$cmd"
}

tdrun() {
  # Usage: tdrun [... trade.py options]
  #
  # Calculates a trade run for your current ship using trade.py

  local args=(
    --pad=$(.td_tool --stat pad_size)
    --ly=${TD_LADENLY:-$(.td_tool --stat laden_ly)}
    --empty=${TD_EMPTYLY:-$(.td_tool --stat unladen_ly)}
    --cap=${TD_CAP:-$(.td_tool --stat cargo_cap)}
    --cr=$(.td_tool --cr)
    --insurance=$(.td_tool --stat rebuy)
    --prune-score=${TD_PRUNE_SCORE:-5}
    --prune-hops=${TD_PRUNE_HOPS:-4}
    --jumps=${TD_JUMPS}
    "${TD_RUN_ARGS[@]}"
    "$@"
  )
  echo \$ trade run "${args[@]}"
  trade run "${args[@]}"
  echo -ne '\a'
}

tdrunfrom() {
  local origin="$1"
  shift 2>/dev/null
  if [[ -z $origin || $origin == -* ]]; then
    origin="$(.td_tool --station)"
    echo "NOTE: using ${origin} as the origin"
  fi

  tdrun --from="$origin" "$@"
}

tdrunto() {
  local dest="$1"
  shift 2>/dev/null
  if [[ -z $dest || $dest == -* ]]; then
    dest="$(.td_tool --station)"
    echo "NOTE: using ${dest} as the origin"
  fi

  tdrun --to="$dest" "$@"
}

tdrunloop() {
  local origin="$1"
  shift 2>/dev/null
  if [[ -z $origin || $origin == -* ]]; then
    origin="$(.td_tool --station)"
    echo "NOTE: using ${origin} as the origin"
  fi

  tdrun --from="$origin" --loop "$@"
}

tdup() {
  echo \$ trade import --plug=eddblink "$@"
  trade import --plug=eddblink "$@"
}

### custom internal functions

.trade_force_update_edapi() {
  trade import --plug=edapi -O tdh &>/dev/null
}

.trade_update_edapi() {
  local maxAge="5" # minutes
  if [[ ! -f "$TD_TMP"/tdh_profile.json ]]; then
    echo Updating commander data from cAPI >&2
    .trade_force_update_edapi
  elif [[ -n "$(find "$TD_TMP"/tdh_profile.json -mmin +${maxAge})" ]]; then
    # NOTE: do not use .td_tool here, recursion trap
    local cmdr_name=$(td_tool.py --name)
    cmdr_name=${cmdr_name:+CMDR $cmdr_name}
    echo Updating ${cmdr_name:-commander} data from cAPI >&2
    .trade_force_update_edapi
  fi
}

.td_tool() {
  .trade_update_edapi && td_tool.py "$@"
}
