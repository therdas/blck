# Proper pythonic import
# Why am i doing this
# oh pls send halp


# We need this
# lmao
import.rename-funcs() {
    declare -F $1 > /dev/null || return 1
    eval "$(echo "${2}()"; declare -f ${1} | tail -n +2)"
    unset -f $1
}

import.find-funcs() {
    scr=$(cat $1)
    scr='#!/bin/zsh
    for f in ${(ok)functions}; do
        unset -f $f
    done
    '"$scr"'
    IFS=$'\n'
    print -rl ${(ok)functions}
    '
    out=$(zsh -c "$scr")
    echo "$out"
}

