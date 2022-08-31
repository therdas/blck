blck.palette.update() {
    local index=$1
    local value=$2

    __blck_palette[$index]=$value
}

blck.palette.update-palettes() {
    __blck_palette=($(echo $__blck_palettes[$__blck_use_palette]))
}