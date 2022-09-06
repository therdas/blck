# Locals

__blck_hooks_resize_last_lines=''
__blck_hooks_resize_last_cols=''

blck.hooks.resize.record() {
    __blck_hooks_resize_last_cols="$(tput cols)"
    __blck_hooks_resize_last_lines="$(tput lines)"
}

blck.hooks.resize.record

blck.hooks.resize.get-prompt-line-diff() {
    local cur_line="$(tput lines)"
    local cur_cols="$(tput cols)"
    local last_cols="$__blck_hooks_resize_last_cols"
    local line_diff="$(( $last_cols/$cur_cols - 1))"

    echo "$line_diff"
}

blck.hooks.resize.get-line-diff() {
    echo "$(($(tput lines) - $__blck_hooks_resize_last_lines))"
}