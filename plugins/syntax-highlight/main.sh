blck.plugins.highlight.load () {
    source $BLCK_HOME/plugins/syntax-highlight/$__blck_opts[highlighter]
}

blck.plugins.highlight.theme.list() {
    for file in "$BLCK_HOME/themes/highlight/"*".zsh-syntax-theme"; do
        echo $(basename $file '.zsh-syntax-theme')
    done
}

blck.plugins.highlight.theme.set() {
    if [ ! -f $BLCK_HOME/themes/highlight/$1.zsh-syntax-theme ]; then
        return 1
    fi

    source $BLCK_HOME/themes/highlight/$1.zsh-syntax-theme
}

((${+__blck_opts[highlighter]})) && blck.plugins.highlight.load
((${+__blck_opts[highlight-theme]})) && blck.plugins.highlight.theme.set $__blck_opts[highlight-theme]

# Print help
blck.plugins.highlight.help() {
    echo "Usage: highlight theme set <theme>
                       list"
}

# Dispatcher
blck.plugins.highlight.dispatch() {
    if [ $# -lt 1 ]; then
        echo "Expecting one action"
        blck.plugins.highlight.help
        return
    fi;

    case $1 in
        'theme')  
                if [ $# -lt 2 ]; then
                    echo "highlight theme: expecting a keyword"
                    blck.plugins.highlight.help
                    return
                fi
                
                case $2 in
                    'set')
                        if [ $# -ne 3 ]; then
                            echo "highlight theme set: expecting theme name"
                            blck.plugins.highlight.help
                            return
                        fi

                        blck.plugins.highlight.theme.set "$3"
                        if [ $? -eq 0 ]; then
                            echo "Changed highlight theme to $3"
                        else
                            echo "Highlight theme not found, check list of available themes with \`highlight theme list\`"
                        fi
                        ;;

                    'list')
                        blck.plugins.highlight.theme.list
                        ;;
                    *)
                        echo "Invalid keyword at $2"
                        blck.plugins.highlight.help
                        ;;
                esac
                ;;   
        *)
            echo "Invalid keyword at $2"
            blck.plugins.highlight.help
            ;;
    esac
}

# Putting in hooks
blck.plugins.register highlight blck.plugins.highlight.dispatch