blck.palette.update() {
    if [ "$1" -lt 1 -o "$1" -gt "${#__blck_palette[@]}" ]; then
        return 1
    fi

    local index=$1
    local value=$2

    __blck_palette[$index]=$value
    return 0
}

blck.palette.refresh-palette() {
    __blck_palette=($(echo $__blck_palettes[$__blck_use_palette]))
}

blck.palette.resolve_alias() {
    # Simple linear search enough, not performance critical.
    for i in $(seq 1 $#__blck_palette_aliases[@]); do
        if [ "$__blck_palette_aliases[$i]" = "$1" ]; then
            echo $i
            return
        fi
    done
    echo "-1"
}

blck.palette.use() {
    ind=$1
    if ! [[ $1 =~ '^[0-9]+$' ]]; then
        ind=$(blck.palette.resolve_alias $1)
    fi

    if [ $ind -ge 1 -a $ind -le $#__blck_palettes[@] ]; then
        __blck_use_palette="$ind"
        blck.palette.refresh-palette
        return 0
    fi

    return 1
}

blck.palette.dump() {
    local v=0
    for i in $__blck_palette[@]; do
        v=$((v+1))
        print -P -f "%4s %4s %s" "@$v" "%K{$i}    %k" "$i
"
    done
}

blck.palette._pdump() {
    local collist=($(echo "$@"))
    local v=0
    for i in "${collist[@]:1:8}"; do
        v=$((v+1))
        echo -n "%K{$i}  %k"
    done
}

blck.palette.list() {
    for i in $(seq 1 $#__blck_palettes); do
        print -P "$i $(blck.palette._pdump $__blck_palettes[$i]) $__blck_palette_aliases[$i] "
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

blck.palette.print_cmd_list () {
    echo "Usage: palette use <name>
             palette list
             palette change @<int> <color>
             palette dump <name>
             palette set-raw <color> [<color>...]"
}

blck.palette.dispatcher() {
    if [ $# -lt 1 ]; then
        echo "palette: Expecting one action"
        blck.palette.print_cmd_list
        return
    fi;

    case $1 in
        'use')  
                if [ $# -ne 2 ]; then
                    echo "palette use: Expecting an argument"
                    blck.palette.print_cmd_list
                    return
                fi
                
                blck.palette.use $2
                if [ $? -eq 0 ]; then
                    echo -n "palette use: Using palette $__blck_use_palette"
                    echo -n " '$__blck_palette_aliases[$__blck_use_palette]'"
                    echo " from $__blck_opts[theme]."
                else
                    echo "palette use: Palette not found, check list of available palettes with \`palette list\`"
                fi
                ;;
        'list')
                blck.palette.list
                ;;
        'dump')
                blck.palette.dump
                ;;
        'change')
                if [ $# -ne 3 ]; then
                    echo "palette change: Expecting two arguments, one positional and one color"
                    blck.palette.print_cmd_list
                    return
                fi
                blck.palette.update $2 $3
                if [ $? -ne 0 ]; then
                    echo "palette change: Index out of bounds (Hint: do not use the @ reference symbol)"
                fi
                ;;
        'set-raw') 
                if [ $# -lt 2 ]; then
                    echo "palette set-raw: Expecting at least two arguments"
                    blck.theme.print_cmd_list
                    return
                fi

                blck.palette.undump ${@:2}
                ;;
        *)
                echo "palette: Invalid keyword at '$1'"
                blck.palette.print_cmd_list
                ;;
    esac
}

blck.cmd.register palette blck.palette.dispatcher