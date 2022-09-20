# Locals
zmodload zsh/mathfunc
__blck_hooks_resize_last_lines=''
__blck_hooks_resize_last_cols=''

blck.hooks.resize.record() {
    __blck_hooks_resize_last_cols="$(tput cols)"
    __blck_hooks_resize_last_lines="$(tput lines)"
}

blck.hooks.resize.record

blck.hooks.resize.get-prompt-line-diff() {
    local cur_cols="$(tput cols)"".0"
    local last_cols="$__blck_hooks_resize_last_cols"".0"
    local diff=0
    if [ `tput cols` -lt $__blck_hooks_resize_last_cols ]; then
        diff="$(( int(ceil($last_cols/$cur_cols)) ))"
    fi
    echo "$diff"
}

blck.hooks.resize.get-line-diff() {
    echo "$(($(tput lines) - $__blck_hooks_resize_last_lines))"
}