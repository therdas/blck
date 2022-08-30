blck.segment.interpret-prefix-string() {
  local string=$1

  if [[ ${string:0:1} == '&' ]]; then
    string=${string:1}
    string="$(${string%% })"
    if [[ -n $string ]];  then
      echo "$__blck_pad$string$__blck_pad"
    fi
  elif [[ ${string:0:1} == "@" ]]; then
    string=${string:1}
    string="$__blck_palette[$string]"
    echo "$string"
  else
    echo "$__blck_pad$string$__blck_pad"
  fi
}

blck.segment.fill() { 
    zparseopts -D -E -- \
        b:=bgcolor f:=color p=pad

    local text="$@"
    echo -n '%F{'"${color[-1]// }"'}%K{'"${bgcolor[-1]// }"'}'"$text"'%f%k'
}   

blck.segment.parse() { 
    textinterpret=0
    zparseopts -D -E -- \
        b:=bgcolor f:=color

    local text="$(blck.segment.interpret-prefix-string $@)"
    local bgcolor="$(blck.segment.interpret-prefix-string $bgcolor[-1])"
    local color="$(blck.segment.interpret-prefix-string $color[-1])"

    blck.segment.fill "$text" -b $bgcolor[@] -f $color[@]
} 

blck.segment.create() {
    zparseopts -D -E -- \
        b:=bgcolor f:=color -bg:=bgcolor -fg:=color

    if [[ ${#color[@]} = 0 ]]; then color="-f DEFAULT"; fi
    if [[ ${#bgcolor[@]} = 0 ]]; then bgcolor="-b DEFAULT"; fi

    local text="$@"

    blck.segment.parse $text "${color[@]}" "${bgcolor[@]}"  
}