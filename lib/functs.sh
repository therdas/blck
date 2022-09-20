__blck_time_suffix=' ⌚'

blck.functs.unameAtHost() {
    echo "$USER@$HOST"
}

blck.functs.env.vcs_info() {
  vcs_info
  if [ -z $vcs_info_msg_0_ ]; then return; fi
  echo "$vcs_info_msg_0_"
}

blck.functs.env.py_venv() {
  local virtualenv_path="$VIRTUAL_ENV"

  # Early exit; $virtualenv_path must always be set.
  [[ -z "$virtualenv_path" ]] && return

  echo "${virtualenv_path:t}" 
}


blck.functs.exec.timer() {
    # Don't print on first prompt
    if [ "$__blck_f_is_first" -eq 0 ]; then return 0; fi

    # Get time, don't worry about resetting, leave that to BLCK!
    local a="$__blck_time_lst"  #before decimal
    local b="$__blck_time_lst"  #after decimal

    local sf=1            #we divide by this to make it human-readable
    local umult=''        #and print unit (k, m, b)

    # Do some scaling shenanigans
    if [ "$a" -ge 1000000000 ]; then
        sf=1000000000.0; unit='b' #b for billion
    elif [ "$a" -ge 1000000 ];  then
        sf=1000000.0;    unit='m' #m for mega/million
    elif [ "$a" -ge 1000 ];     then
        sf=1000.0;       unit='k' #k for kilo/thousand
    fi

    if (( sf > 2.0 )); then      #significant sf, do truncation
        a=$((a/sf))
        printf "%.3g$unit$__blck_time_suffix" "$a"  #this is what will be shown. Don't use newlines!
    else
        printf "$a$__blck_time_suffix"
    fi
}