blck.cmd.theme_dispatch() {
    case "$1" in
        'set') blck.theme.set "$2"; echo "Changed theme to $2";;
        'list') blck.theme.list;;
        'install') blck.theme.install "$2";;
        *)echo "blck.Theme: Unrecognized command";;
    esac
}

blck.cmd.change_palette() {
    echo $@
}

blck.palette.dispatch() {
    echo $@
}