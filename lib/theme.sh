import lib.palette

blck.theme.set() {
    declare -g -A blck_config
    tpath="$BLCK_HOME/themes/$1.zsh-theme"
    source $tpath
    blck.theme.copy-theme-var
    blck.theme.unset-theme-var
    blck.palette.update-palettes

    $__blck_on_theme_load
}

blck.theme.list() {
    for file in "$BLCK_HOME/themes/"*".zsh-theme"; do
        echo $(basename $file '.zsh-theme')
    done
}

blck.theme.install() {
    cp $1 "$BLCK_HOME/themes/$(basename $1 '.zsh-theme').zsh-theme"
}

blck.theme.copy-theme-var() {
    __blck_tlprompt_segments=("${left_prompt[@]}")
    __blck_trprompt_segments=("${right_prompt[@]}")
    __blck_blprompt_segments=("${bottom_left_prompt[@]}")
    __blck_otprompt_segments=("${other_prompts[@]}")
    __blck_hooks_pre_prompt=("${hooks_before_prompt[@]}")
    __blck_hooks_pre_exec=("${hooks_before_exec[@]}")
    __blck_hooks_pre_accept=("${hooks_before_accept[@]}")
    __blck_hooks_post_resize=("${hooks_after_resize[@]}")
    __blck_palettes=("${palettes[@]}")
    __blck_use_palette="$blck_config[palette]"
    __blck_uname="$blck_config[uname]"
    __blck_host="$blck_config[host]"
    __blck_lines="$blck_config[lines]"
    __blck_on_theme_load="$hook_on_load"
}

blck.theme.unset-theme-var() {
    unset hook_on_load palettes left_prompt right_prompt bottom_left_prompt other_prompts blck_config hooks_after_resize hooks_before_prompt hooks_before_exec hooks_before_accept
}