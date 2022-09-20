declare -g -A __blck_cmd_map

blck.cmd.register() {
    if [ $# -ne 2 ]; then
        return
    fi

    __blck_cmd_map[$1]="$2"
}

blck.cmd.trigger() {
    if ((${+__blck_cmd_map[$1]})); then
        $__blck_cmd_map[$1] "${@:2}"
        return true
    else
        return false
    fi
}

blck.cmd.reset() {
    unset __blck_cmd_map
    declare -g -A __blck_cmd_map
}