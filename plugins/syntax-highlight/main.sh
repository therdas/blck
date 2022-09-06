blck.plugins.syntax-highlighting.load () {
    source $BLCK_HOME/plugins/syntax-highlight/$__blck_opts[highlighter]
}

#Extend: theme
blck.theme.set-syntax-theme() {
    source $BLCK_HOME/themes/syntax-highlight/$1.zsh-syntax-theme
}

((${+__blck_opts[highlighter]})) && blck.plugins.syntax-highlighting.load
((${+__blck_opts[highlight-theme]})) && blck.theme.set-syntax-theme $__blck_opts[highlight-theme]
