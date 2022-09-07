blck.palette.update() {
    if [ "$1" -ge 1 -o "$1" -le "${#__blck_palette[@]}" ]; then
        return 1
    fi

    local index=$1
    local value=$2

    __blck_palette[$index]=$value
}

blck.palette.update-palettes() {
    __blck_palette=($(echo $__blck_palettes[$__blck_use_palette]))
}

blck.palette.dump() {
    local v=0
    for i in $__blck_palette[@]; do
        v=$((v+1))
        print -P -f "%4s %4s %s" "@$v" "%K{$i}    %k" "$i
"
    done
}

blck.palette.undump() {
    __blck_palette=($(echo "$@"))
}

blck.palette.disable-color() {
    for i in "$(seq 1 ${#__blck_palette[@]})"; do
        __blck_palette[i]="default"
    done
}

blck.palette.enable-color() {
    blck.palette.update
}

blck.palette.dispatcher() {
    
}

blck.cmd.register palette blck.palette.dispatcher