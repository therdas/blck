declare -g -A __blck_plugins_map

blck.plugins.load() {
    IFS=, read -A plugs <<< "$__blck_opts[plugins]"
    for v in "$plugs[@]"; do
        source $BLCK_HOME/plugins/$v/main.sh
    done
}

blck.plugins.register() {
    __blck_plugins_map[$1]="$2"
}

blck.plugins.list() {
    for file in "$BLCK_HOME/plugins/"*"/"; do
        echo $(basename $file)
    done
}

blck.plugins.dispatch() {
    if [ $# -lt 1 ]; then
        echo "plugin: Expecting a keyword"
        echo "        For help with builtins, use \`plugin help\`"
        echo "        For a list of all installed plugins, use \`plugin list\`"
        return 1
    fi

    case $1 in
        'install')
                if [ $# -lt 2 ]; then
                    echo "plugin install: Expecting a directory"
                    echo "                Use \`plugin help\`"
                    return 1
                fi

                blck.plugins.install-blck-plug $2
            ;;
        'install-zsh-plugin')
                if [ $# -lt 4 ]; then
                        echo "plugin install-zsh-plugin: Expecting three arguments (format <name> <entry-script> <folder>"
                        echo "                           Use \`plugin help\`"
                        return 1
                    fi

                    blck.plugins.install-external-plug "$2" "$3" "$4"
            ;;
        'remove')
                if [ $# -lt 3 ]; then
                    echo "plugin remove: Expecting the name of plugin(s)"
                    echo "               Use \`plugin help\`"
                    return 1
                fi

                for i in "${@:2}"; do
                    blck.plugins.remove-plugin $i
                done
            ;;
        'list')
                blck.plugins.list
            ;;
        'install-remote')
                echo "This feature has not been implemented yet ;)"
            ;;
        'update')
                echo "This feature has not been implemented yet ;)"
            ;;
        *)
            if ((${+__blck_plugins_map[$1]})); then
                $__blck_plugins_map[$1] "${@:2}"
            else
                echo "plugin $1: No such plugin namespace has been registered with blck CLI"
            fi
            ;;
    esac
}

blck.plugins.install-blck-plug() {
    if [ ! -d $1 ]; then
        return 1
    fi

    cp -r $1 $BLCK_HOME/plugins
    echo "Installed $1. To use it, edit your .blckrc file!"
}

blck.plugins.install-external-plug() {
    if [ ! -d $3 ]; then
        return 1
    fi

    mkdir -p $BLCK_HOME/plugins/$1/$1
    cp -r $3/* $BLCK_HOME/plugins/$1/$1
    echo "source $BLCK_HOME/plugins/$1/$1/$2" > $BLCK_HOME/plugins/$1/main.sh
    echo "Installed $1. To use it, edit your .blckrc file!
You might also want to edit $BLCK_HOME/plugins/$1/main.sh"
}

blck.plugins.remove-plugin() {
    local p=$BLCK_HOME/plugins/$1
    
    if [ ! -d "$p" ]; then
        echo "Cannot find plugin $1. (Make sure you're using the actual name, not the CLI alias)"
        return 1
    fi

    echo -n "Are you sure you want to delete the plugin $1, found at $p? [YN]: "
    read response

    if [ "${response:l}" = 'y' ]; then
        rm -rf $p
        echo "Removed $1"
    else
        echo "No changes made"
    fi
}

blck.cmd.register plugin blck.plugins.dispatch