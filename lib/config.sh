declare -g -A __blck_opts

blck.config.read-blckrc () {
    config="$(cat ~/.blckrc | sed -n 's/^\s*\([0-9A-Za-z\-]*\)\s*=\s*\([^ #]*\).*$/\1:\2/p')"
    echo "$config" | while IFS=':' read -r k v; do
        __blck_opts[$k]="$v"
    done
}

blck.config.change-blckrc() {
    new_config="$(cat ~/.blckrc | sed 's/^\(\s*\)\('"$1"'\)\(\s*=\s*\)\([^ #]*\)\(.*\)$/\1'""$1""'\3'""$2""'\5/')"
    echo $new_config > ~/.blckrc
}



blck.config.print_cmd_list () {
    echo "Usage: config refresh
             config change <key> <value>
             config whatis <option>"
}

__blck_conf_cli_flag=0

blck.config.dispatcher() {
    if [ $# -lt 1 ]; then
        echo "config: Expecting one action"
        blck.config.print_cmd_list
        return
    fi;

    [ $__blck_conf_cli_flag -eq 0 ] && echo "config: warn: The config CLI is still in very early alpha. Use with extreme caution." && __blck_conf_cli_flag=1

    case $1 in
        'refresh')  
                echo "config refresh: Warn: Refreshing the config may not have effect unless the module rechecks.
                Rereading config file..."
                blck.config.read-blckrc
                ;;
        'change') 
                if [ $# -ne 3 ]; then
                    echo "config change: Expecting two arguments"
                    blck.config.print_cmd_list
                    return
                fi
                blck.config.change-blckrc $2 $3
                ;;
        'whatis') 
                if [ $# -ne 2 ]; then
                    echo "config whatis: Expecting one argument"
                    blck.config.print_cmd_list
                    return
                fi

                if [ -n "$__blck_opts[$2]" ]; then
                    echo "config whatis: $2 = $__blck_opts[$2]"
                else
                    echo "config whatis: option not set"
                fi

                ;;
        *)
                echo "config: Invalid keyword at '$1'"
                blck.theme.print_cmd_list
                ;;
    esac
}

blck.cmd.register config blck.config.dispatcher