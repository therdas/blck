#-----------------------------------------------------
# Color Definitions
#-----------------------------------------------------

# If you want to define alternate palettes, this is the place to do so
# How is a palette used?
# > A palettes is basically a whitespace delimited string of hex codes, WITH # prefix
# > When using a palette, just use the number with an @, for example, @1 is the second
# > color in the palette. A simple palette is just a singleton array with one such string
# Why an array?
# > To allow a) randomization of colorscheme every boot
# >          b) choosing a colorscheme at start
# What if I don't want to >:D ?
# > Hey, you do you, hardcode as many hexes you want! Not worth it tho.
# Choose a palette in configuration options by using palette <int>.

# Personal Advice, make a palette, after each color insert another that can be used as text
# with the original color as a background. So each 2*n+1 is a bg, and 2*n+2 is fg.

palettes=(
  '#700142 #D6027E #F431F7 #69156a #DE94F7 #30246D #B076C4 #3E22AB #9A67AB #22135E DEFAULT DEFAULT white red #555555 DEFAULT #404040 DEFAULT red green'
  '#FF0000 #D6027E #F431F7 #69156a #DE94F7 #30246D #B076C4 #3E22AB #9A67AB #22135E DEFAULT DEFAULT white red #555555 DEFAULT #404040 DEFAULT red green'
  'red blue #b24201 #F28807 #b04203 #F5B74A #4084bf #00315B #bacdde #005AA8 #F35C04 #bd4805 #F28807 #bd4805 #777777 default #F35C04'
)

# This is only used for identification
# Personal Advice, usually blck uses the first four colors while displaying a list of palettes
# so, ensure that your primary palette colors are in the first four slots. To check how this
# looks, try out `blck palette list`
palette_aliases=(
  'debug1'
  'debug2'
  'autumn-night'
)

#-----------------------------------------------------
# Configuration Options
#-----------------------------------------------------

# Theme Configuration
# Arrays: left_prompt: Defines the top left prompt.
#         right_prompt: Defines the top right prompt.
#         bottom_left_prompt: Defines the bottom left prompt
#         bottom_right_prompt: Defines the bottom right prompt <TODO: Implement
#
#
# What are the values?
# >   Key: Index (where to be shown, left to right, 1 to N. As is normal array, don't mention specially).
#          Exception -> In case of continuity prompts, position Matters! First is the PS2 (first line)
#                       this is the PS2 prompt at point where that begins. The second index is the
#                       prompt used the second line onwards. You can do a lot using these 👀
# > Value: This one is a bit tricky. It is of the format <PROMPT_TEXT>:<FG_COLOR>:<BG_COLOR>
#          PROMPT_TEXT: As expected, text to be shown
#          FG_COLOR:    Color of the text
#          BG_COLOR:    Color of the background of the text
# >>       To put these in dynamically, use a & in front of any of these, and these will be treated
# >>       as shell functions to execute and replace the actual invocation with.
# >>       Example: If the text is &getpyenv, it will call the function getpyenv(), grab output text
# >>                and replace the &getpyenv with it. Same applies to colors. For more details, see
# >>                the sample function below, one for text, the other color. 
# >>       If you want to use the character ':' either use Unicode, escape it, or define a dynamic func.

left_prompt=(
  '&blck.functs.env.py_venv:@7:@8'
  '%Bλ%b:@1:@2'
  'therdas@eos:@3:@4'
  '%1~:@5:@6'
)

right_prompt=(
  '&blck.functs.env.vcs_info:@9:@10'
  '&blck.functs.exec.timer:@7:@8'
)

bottom_left_prompt=(
  "❱:@13:@14"
)

other_prompts=(
  'PS2'      "…:@15:@16"
  'echo'     "❱:@2:@16"
  'PS2-echo' "┆:@15:@16"
)

# Options
#          palette: which element of `palettes` array to use to get colors
#            uname: custom UNAME, do not obtain from env if this is present
#             host: custom HOSTNAME, do not obtain from env if this is present
#              pad: the padding to use in segments, define as integer, uses space
#            lines: no. of prompt lines to use, default 2

blck_config=(
  'palette'               '3'
  'uname'                 'therdas'
  'host'                  'eiar'
  'pad'                   '2'
  'lines'                 '2'
)

hooks_after_resize=(
  'therdas.blocky_theme.hook.resize'
)

hooks_before_prompt=(
  'therdas.blocky_theme.hook.update_stat_color'
)

hooks_before_exec=(

)

hooks_before_accept=(

)

hook_on_load="therdas.blocky_theme.hook.on_theme_load"

#-----------------------------------------------------
# Dynamic Functions
#-----------------------------------------------------

# A dynamic function is... drumroll... a function.
# Yay
# In seriousness, it is a function that is present in the theme file that allows
# us to customize prompts _within_ command-to-command scope instead of shell-to
# -shell scope. To return text for a segment, just make a function that echos a 
# string. (Use print -P, printf or echo, your choice, internally print -P is used)
# You have access to a few helpers: 1. __blck-t-length(): echos length of string without ASCII Escapes
#                                   2. __blck-t-string(): echos string without ASCII Escapes
#                                   3. $__blck_pad: the padding defined in configuration
#                                   4. $__blck_last_ecode: exit code of last command
#                                   5. $__blck_time_lst: time since last command, init to 0
#                                   6. $__blck_f_is_first: binary (0=true, 1=false) flag, true if first
#                                                          prompt since shell start
#                                   7. $__blck_f_is_new_cmd: binary (0=true, 1=false) flag, true if first
#                                                            line of new command


# Here's an example: timer-func (to get the time since last command, for exec time)
# We use this in right_prompt

# timer-func() {
#     # Don't print on first prompt
#     if [ $FIRST_PROMPT -eq 0 ]; then return 0; fi

#     # Get time, don't worry about resetting, leave that to `BLC`K!
#     a="$TIME_LAST"  #before decimal
#     b="$TIME_LAST"  #after decimal

#     sf=1            #we divide by this to make it human-readable
#     umult=''        #and print unit (k, m, b)

#     # Do some scaling shenanigans
#     if [ $a -gt 1000000000 ]; then
#         sf=1000000000; unit='b' #b for billion
#     elif [ $a -gt 1000000 ];  then
#         sf=1000000;    unit='m' #m for mega/million
#     elif [ $a -gt 1000 ];     then
#         sf=1000;       unit='k' #k for kilo/thousand
#     fi

#     if [ $sf -gt 2 ]; then      #significant sf, do truncation
#         a=$((value/sf))
#         b=$((value%sf))
#         printf "$a.$b$unit ⌚"  #this is what will be shown. Don't use newlines!
#     else
#         printf "$a ⌚"
#     fi

#     return
# }

# To explore the standard functions, go to TODO:MODULE-STD and check the functions out, they're
# pretty mundane.

therdas.blocky_theme.hook.update_stat_color() {
    #You can also call blck.palette.use_palette x
    #this allows for even more shenanigans, believe it or not :p
    if [ $__blck_last_ecode -eq 0 ]; then
        blck.palette.update 13 '#bd4805'
        blck.palette.update 14 '#F28807'
    else 
        blck.palette.update 13 '#d23902'
        blck.palette.update 14 '#fd9f68'
    fi
}

alias clear="blck.std.misc.clear-to-bottom"
alias c=clear

therdas.blocky_theme.hook.resize() {
  blck.hooks.resize.get-prompt-line-diff

  local htd=0
  local ld="$(blck.hooks.resize.get-line-diff)"
  local pld="$(blck.hooks.resize.get-prompt-line-diff)"
  for i in $(seq 1 $pld); do
    tput cuu1
    htd=1
  done

  if [ $htd -eq 0 ]; then
    tput cuu1
  fi

  tput el1
  tput ed
  precmd
  zle reset-prompt 

  blck.hooks.resize.record
}

therdas.blocky_theme.hook.on_theme_load () {
  clear
}