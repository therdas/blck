function import(){
  if [ "$#" -eq 1 ]; then
    source $BLCK_HOME/${1//\./\/}.sh
  fi
}

__blck_theme="pumpkin-spice"

import lib.std.all
import lib.theme

blck.theme.set $__blck_theme

import lib.prompt
import lib.init
import lib.cmd
import lib.functs

setopt  prompt_subst
setopt  inc_append_history_time
autoload -Uz vcs_info

function echohey() {
  echo "hey"
}

function preexec() {
  __blck_temp_timer="$(($(date +%s%0N)/1000000))"

    # This is where the hooks are processed
  for i in "$__blck_hooks_pre_exec[@]"; do
    $i
  done
}

function precmd() {
  __blck_last_ecode="$?"

  zparseopts -D -E -- \
        -noecho=ne
  
  if [ $__blck_temp_timer ]; then
    local now=$(($(date +%s%0N)/1000000))
    __blck_time_lst=$(($now-$__blck_temp_timer))
  fi

  # This is where the hooks are processed
  for i in "$__blck_hooks_pre_prompt[@]"; do
    $i
  done

  blck.prompt.update
  blck.prompt.assign

  __blck_f_is_first=1
  __blck_f_is_new_cmd=0
  unset __blck_temp_timer
}



TRAPWINCH () {
  # This is where the hooks are processed
  for i in "$__blck_hooks_post_resize[@]"; do
    $i
  done
}

function _reset-prompt-and-accept-line {
  if [ $__blck_f_is_new_cmd -eq 0 ]; then
    print -Pn "\033[2K\033[A\033[2K\r$__blck_otprompt_processed[echo]"
    __blck_f_is_new_cmd=1
  else
    print -Pn "\033[2K\033[A\033[2K\r$__blck_otprompt_processed[PS2-echo]"
  fi
  printf "%s" "$BUFFER"

  # This is where the hooks are processed
  for i in "$__blck_hooks_pre_accept[@]"; do
    $i
  done

  zle .accept-line     # Note the . meaning the built-in accept-line.
}


blck() {
  case "$1" in 
    'theme') blck.cmd.theme_dispatch "${@:2}";;
    'palette') blck.palette.dispatch "${@:2}";;
    'refresh') blck.cmd.reinit; blck.cmd.change_theme $__blck_theme;;
    'reset') blck.cmd.reinit;;
    '*') echo "command not supported: try seeing the docs maybe?";;
  esac
}



source $BLCK_HOME/themes/pumpkin-spice.zsh-theme

if [ $__blck_f_enable_git -eq 0 ]; then
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr "$__blck_stagedstr"
  zstyle ':vcs_info:*' unstagedstr "$__blck_unstagedstr"
  zstyle ':vcs_info:*' formats "$__blck_formats"
  zstyle ':vcs_info:*' actionformats "$__blck_actionformats"
else
  zstyle ':vcs_info:*' disable git
fi

zle -N accept-line _reset-prompt-and-accept-line
touch "$HOME/.trd.termcap"

source $BLCK_HOME/themes/zsh-syntax-highlighting/darkcula.zsh-syntax-theme