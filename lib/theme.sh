import lib.palette

blck.theme.set() {
    tpath="$BLCK_HOME/themes/$1.zsh-theme"

    if [ ! -f $tpath ]; then
        return 1
    fi

    if [ -n $__blck_on_theme_unload ]; then
        $__blck_on_theme_unload
    fi

    declare -g -A blck_config
    declare -g -A other_prompts

    source $tpath
    blck.theme.unset-tconf-var
    blck.theme.copy-theme-var
    blck.theme.unset-theme-var
    blck.palette.refresh-palette
    
    if [ -n $__blck_on_theme_load ]; then
        $__blck_on_theme_load
    fi

    blck.config.change-blckrc theme $1
}

blck.theme.list() {
    for file in "$BLCK_HOME/themes/"*".zsh-theme"; do
        echo $(basename $file '.zsh-theme')
    done
}

blck.theme.install() {
    if [ ! -f $1 ]; then
        return 1
    fi

    cp $1 "$BLCK_HOME/themes/$(basename $1 '.zsh-theme').zsh-theme"
}

blck.theme.unset-tconf-var() {
    unset __blck_tlprompt_segments __blck_trprompt_segments __blck_blprompt_segments __blck_otprompt_segments __blck_hooks_pre_prompt
    unset __blck_hooks_pre_exec __blck_hooks_pre_accept __blck_hooks_post_resize __blck_palettes __blck_palette_aliases __blck_use_palette 
    unset __blck_uname __blck_host __blck_lines __blck_on_theme_load __blck_on_theme_unload __blck_hooks_post_accept
}

blck.theme.copy-theme-var() {
    __blck_tlprompt_segments=("${left_prompt[@]}")
    __blck_trprompt_segments=("${right_prompt[@]}")
    __blck_blprompt_segments=("${bottom_left_prompt[@]}")

    if [ -n "$other_prompts" ]; then 
        declare -g -A __blck_otprompt_segments
        __blck_otprompt_segments=("${(kv)other_prompts[@]}")
    fi

    __blck_hooks_pre_prompt=("${hooks_before_prompt[@]}")
    __blck_hooks_pre_exec=("${hooks_before_exec[@]}")
    __blck_hooks_pre_accept=("${hooks_before_accept[@]}")
    __blck_hooks_post_accept=("${hooks_after_accept[@]}")
    __blck_hooks_post_resize=("${hooks_after_resize[@]}")
    __blck_palettes=("${palettes[@]}")
    __blck_palette_aliases=("${palette_aliases[@]}")

    if [ -n "$blck_config" ]; then
        __blck_use_palette="$blck_config[palette]"
        __blck_uname="$blck_config[uname]"
        __blck_host="$blck_config[host]"
        __blck_lines="$blck_config[lines]"
    fi

    if [ -n $hook_on_load ]; then
        __blck_on_theme_load="$hook_on_load"
    fi

    if [ -n $hook_on_unload ]; then
        __blck_on_theme_unload="$hook_on_unload"
    fi
}

blck.theme.unset-theme-var() {
    unset hook_on_load hook_on_unload palettes palette_aliases left_prompt right_prompt bottom_left_prompt other_prompts blck_config hooks_after_resize hooks_before_prompt hooks_before_exec hooks_before_accept
}

blck.theme.print_cmd_list () {
    echo "Usage: theme set <theme>
             theme list
             theme install <path>"
}

blck.theme.dispatcher() {
    if [ $# -lt 1 ]; then
        echo "theme: Expecting one action"
        blck.theme.print_cmd_list
        return
    fi;

    case $1 in
        'set')  
                if [ $# -ne 2 ]; then
                    echo "theme set: Expecting three arguments"
                    blck.theme.print_cmd_list
                    return
                fi
                
                blck.theme.set "$2"
                if [ $? -eq 0 ]; then
                    echo "Changed theme to $2"
                else
                    echo "Theme not found, check list of available themes with \`theme list\`"
                fi
                ;;
        'list')
                blck.theme.list
                ;;
        'install') 
                if [ $# -ne 2 ]; then
                    echo "theme install: Expecting three arguments"
                    blck.theme.print_cmd_list
                    return
                fi

                blck.theme.install "$2";

                if [ $? -eq 0 ]; then
                    echo "Installed theme $(basename $2 '.zsh-theme')\nTry it with \`theme set $(basename $2 '.zsh-theme')\`!"
                else
                    echo "Could not find the zsh-theme file \"$2\""
                fi

                ;;
        *)
                echo "theme: Invalid keyword at '$1'"
                blck.theme.print_cmd_list
                ;;
    esac
}

# Create CMD Hooks
blck.cmd.register theme blck.theme.dispatcher