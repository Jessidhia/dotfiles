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
export TD_PRUNE_HOPS=3        # after 3 hops
export TD_PRUNE_SCORE=20      # percentage

# Maximum number of jumps between hops
export TD_JUMPS=6

# additional default arguments to give to tdrun
export TD_RUN_ARGS=(
  -vv
  --progress
  --fc=N
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

  local near="$1"; shift
  local prod="$1"; shift
  if [[ -n $near && ( -z $prod || $prod == -* ) ]]; then
    # assume station was elided
    prod="$near"
    near="$(.trade_get_station)"
    echo "NOTE: using ${near} as the origin"
  fi

  if [[ 
          -z $near || $near == -* ||
          -z $prod || $prod == -* 
          ]]
  then
      echo "ERROR: Usage: $0 [<station>] <item> ..."
      return 1
  fi

  local cmd="trade buy -vv --near \"$near\" \"$prod\" $*"
  echo \$ $cmd
  eval "$cmd"
}

tdsellto() {
  # Usage: tdsellto [<station>] <item> [... trade.py options]
  #
  # Finds stations near <station> that are buying <item>

  local near="$1"; shift
  local prod="$1"; shift
  if [[ -n $near && ( -z $prod || $prod == -* ) ]]; then
    # assume station was elided
    prod="$near"
    near="$(.trade_get_station)"
    echo "NOTE: using ${near} as the origin"
  fi

  if [[ 
          -z $near || $near == -* ||
          -z $prod || $prod == -* 
          ]]
  then
      echo "ERROR: Usage: $0 [<station>] <item> ..."
      return 1
  fi

  local cmd="trade sell -vv --near \"$near\" \"$prod\" $*"
  echo \$ $cmd
  eval "$cmd"
}

tdloc() {
  # Usage: tdloc [<place>] <maxly> [... trade.py options]
  #
  # Finds systems and their stations local to <place>
  # that are within <ly> range.

  local place=$1; shift
  local ly=$1; shift
  
  if [[ -n $place && ( -z $ly || $ly == -* ) ]]; then
    # assume station was elided
    ly="$place"
    place="$(.trade_get_station)"
    echo "NOTE: using ${place} as the place"
  fi
  
  if [[ -z $place || $place == -* || -z $ly || $ly == -* ]]
  then
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

  local from=$1; shift
  local to=$1; shift

  if [[ -n $from && ( -z $to || $to == -* ) ]]; then
    # assume "from" was elided
    to="$from"
    from="$(.trade_get_station)"
    echo "NOTE: using ${from} as the origin"
  fi

  local cmd="trade nav --ly ${TD_EMPTYLY:-$(ed_ship_range.py --stat unladen_ly)} \"$from\" \"$to\" $@"
  echo \$ $cmd
  eval "$cmd"
}

tdrun() {
  # Usage: tdrun [... trade.py options]
  #
  # Calculates a trade run from <place> using trade.py

  origin="$1"; shift
  if [[ -z $origin || $origin == -* ]]
  then
    origin="$(.trade_get_station)"
    echo "NOTE: using ${origin} as the origin"
  fi

  local cmd=(trade run
      --pad=$(.trade_get_padsize)
      --ly=${TD_LADENLY:-$(ed_ship_range.py --stat laden_ly)}
      --empty=${TD_EMPTYLY:-$(ed_ship_range.py --stat unladen_ly)}
      --cap=${TD_CAP:-$(ed_ship_range.py --stat cargo_cap)}
      --jumps=${TD_JUMPS}
      --cr=$(.trade_get_cr_balance)
      --prune-score=${TD_PRUNE_SCORE:-5}
      --prune-hops=${TD_PRUNE_HOPS:-4}
      --from="${origin}"
      ${TD_RUN_ARGS[@]}
      $@
  )
  echo \$ ${cmd[@]}
  eval "${cmd[@]}"
}

tdup() {
  trade import --plug=eddblink -O fallback
}

### custom internal functions

.trade_force_update_edapi() {
  trade import --plug=edapi -O tdh &>/dev/null
}

.trade_update_edapi() {
  local maxAge="5" # minutes
  if [[ -n "$(find "$TD_TMP"/tdh_profile.json -mmin +${maxAge})" ]]; then
    local cmdr_name=$(.trade_get_cached_cmdr_name)
    cmdr_name=${cmdr_name:+CMDR $cmdr_name}
    echo Updating ${cmdr_name:-commander} data from cAPI >&2
    .trade_force_update_edapi
  fi
}

.trade_get_station() {
  .trade_update_edapi
  # parsing JSON with regexp? /o\
  local docked="$(grep -Eo '"docked":true' "${TD_TMP}/tdh_profile.json")"
  local lastSystem="$(grep -Eo '"lastSystem"[^}]+"name": *"[^"]+"' "${TD_TMP}/tdh_profile.json" | sed 's/^.*"name"://' | cut -d\" -f2)"
  local lastStarport="$(grep -Eo '"lastStarport"[^}]+}[^}]+"name": *"[^"]+"' "${TD_TMP}/tdh_profile.json" | sed 's/^.*"name"://' | cut -d\" -f2)"
  [[ -n "$docked" ]] && echo "$lastSystem/$lastStarport" || echo "$lastSystem"
}

.trade_get_padsize() {
  .trade_update_edapi
  local shipName="$(grep -Eo '"ship"[^}]+"name": *"[^"]+"' "${TD_TMP}/tdh_profile.json" | sed 's/^.*"name"://' | cut -d\" -f2)"
  case $shipName in
  Anaconda|Type7|Type9|Cutter)
    echo L
    ;;
  Python|Type6|Krait_Light)
    echo ML
    ;;
  Adder)
    echo SML\?
    ;;
  *)
    echo Unknown ship internal name \"${shipName}\", assuming Large pad required >&2
    echo L
  esac
}

.trade_get_cached_cmdr_name() {
  grep -Eo '"commander"[^}]+"name": *"[^"]+"' "${TD_TMP}/tdh_profile.json" 2>/dev/null | sed 's/^.*"name"://' | cut -d\" -f2
}

.trade_get_cmdr_name() {
  .trade_update_edapi && .trade_get_cached_cmdr_name
}

.trade_get_cr_balance() {
  .trade_update_edapi
  grep -Eo '"credits": *[0-9]+' "${TD_TMP}/tdh_profile.json" | sed 's/"credits": *//'
}