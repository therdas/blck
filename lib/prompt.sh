import lib.std.all
import lib.segment

blck.prompt.update_one() {
  local prompt=$1
  blck.std.var.assign $prompt ""
  local seg_array=($(blck.std.arr.get $2))
  for index in {1..$#seg_array}; do;
    local name='' fg='' bg=''
    IFS=: read -r name fg bg <<< `echo ${seg_array[$index]}`
    blck.std.var.assign $prompt "$(blck.std.var.get $prompt)$(blck.segment.create $name -f $fg -b $bg)"
  done 
}

blck.prompt.update() {
  for i in "${__blck_prompt_normal[@]}"; do
    echo $i | IFS=' ' read -r prompt_segments prompt_name
    blck.prompt.update_one $prompt_name $prompt_segments
  done

#   Handle PS2, PS2-cont. Special cases, generalize later, try for ONE LOOP
  for key in "${(k)__blck_otprompt_segments[@]}"; do
    if [ -z $key ]; then
      return 1
    fi

    IFS=: read -r name fg bg <<< `echo ${__blck_otprompt_segments[$key]}`
    __blck_otprompt_processed[$key]="$(blck.segment.create $name -f $fg -b $bg)"
  done
}

blck.prompt.assign() {
  local len_tlp=$(blck.std.true_string.len $__blck_tlprompt_processed)
  local len_trp=$(blck.std.true_string.len $__blck_trprompt_processed)
  local len_blp=$(blck.std.true_string.len $__blck_blprompt_processed)

  local len_mid=$(( $COLUMNS - $len_tlp - $len_trp - 1))
  local str_midpad=$(printf "%"$len_mid"s" "")   

  if [ $len_tlp -eq 0 -a $len_trp -eq 0 ]; then
    if [ $len_blp -eq 0 ]; then
      PROMPT="%% "                          #user should not be unprompted :/
    else
      PROMPT="$__blck_blprompt_processed"
    fi
  else
    PROMPT="$__blck_tlprompt_processed$str_midpad$__blck_trprompt_processed
$__blck_blprompt_processed "
  fi

  if [ $len_tlp -eq 0 -a $len_trp -eq 0 ]; then
    PS2="$__blck_otprompt_processed[PS2] "
  else
    PS2="$__blck_tlprompt_processed$str_midpad$__blck_trprompt_processed
$__blck_otprompt_processed[PS2] "
  fi
}

blck.prompt.set_transient_prompt() {
  PROMPT="$__blck_otprompt_processed[echo]"
  PS2="$__blck_otprompt_processed[PS2-echo]"
}