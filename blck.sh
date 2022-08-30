source $BLCK_PATH/lib/std/all.sh
source $BLCK_PATH/lib/prompt.sh

setopt  prompt_subst
setopt  inc_append_history_time
autoload -Uz vcs_info

source $BLCK_PATH/lib/init.sh

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

  if [ -z $ne ]; then
    tmux capture-pane -pS - > "$HOME/.trd.termcap"
    sed -i '$d' "$HOME/.trd.termcap"
  fi
  
  # set -o localoptions -o extendedglob
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
  clear
  cat "$HOME/.trd.termcap"

  # This is where the hooks are processed
  for i in "$__blck_hooks_post_resize[@]"; do
    $i
  done

  print -P "%F{#484848}𝒊 resized terminal%f"

  precmd --noecho
  zle reset-prompt 
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


source $BLCK_PATH/lib/cmd.sh
blck() {
  case "$1" in 
    'set-theme') blck.cmd.change_theme "${@:2}";;
    'switch-palette') blck.cmd.change_palette "${@:2}";;
    'palette') blck.palette.dispatch "${@:2}";;
    'refresh') blck.cmd.reinit; blck.cmd.change_theme $__blck_theme;;
    'reset') blck.cmd.reinit;;
    '*') echo "command not supported: try seeing the docs maybe?";;
  esac
}



source $BLCK_PATH/themes/pumpkin-spice.zsh-theme
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
load-theme '~/.trd.curtheme'
source $BLCK_PATH/themes/zsh-syntax-highlighting/darkcula.zsh-syntax-theme