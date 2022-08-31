import lib.config

declare -g -A __blck_otprompt_segments
declare -g -A __blck_otprompt_processed

blck.config.read-blckrc "~/.blckrc" ".blckrc"

# OPTS
__blck_pad=' '
__blck_histfile='.blck_histfile'

__blck_f_enable_git=0
__blck_stagedstr='+'
__blck_unstagedstr='-'
__blck_formats='%b %u%c'
__blck_actionformats='%b %u%c'

__blck_f_is_first=0
__blck_f_is_new_cmd=0
__blck_time_lst=0

# Prompt Stuff

__blck_tlprompt_processed=''
__blck_trprompt_processed=''
__blck_blprompt_processed=''

# Handle Properly
__blck_otprompt_processed=(
  'PS2'       '>'
  'echo'      '>'
  'PS2-echo'  '>'
)

__blck_tlprompt_segments=(
  '%Bλ%b:#700142:#D6027E'
  'therdas@eos:#F431F7:#69156a'
  '%1~:#DE94F7:#30246D'
  '&blck.functs.env.py_venv:#9A67AB:#22135E'
)


__blck_trprompt_segments=(
  '&blck.functs.env.vcs_info:#B076C4:#3E22AB'
  '&blck.functs.exec.timer:#9A67AB:#22135E'
)


__blck_blprompt_segments=(
  "❱:DEFAULT:DEFAULT"
)


__blck_otprompt_segments=(
  'PS2'      "…:white:red"
  'echo'     "❱:#555555:DEFAULT"
  'PS2-echo' "┆:#404040:DEFAULT"
)

__blck_prompt_normal=(
  '__blck_tlprompt_segments __blck_tlprompt_processed'
  '__blck_trprompt_segments __blck_trprompt_processed'
  '__blck_blprompt_segments __blck_blprompt_processed'
)

__blck_prompt_assocs=(
  '__blck_otprompt_segments __blck_otprompt_processed'
)

__blck_hooks_pre_prompt=(
)

__blck_hooks_pre_exec=(
)

__blck_hooks_pre_accept=(
)

__blck_hooks_post_resize=(
)