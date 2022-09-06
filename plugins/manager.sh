blck.plugins.load() {
    IFS=, read -A plugs <<< "$__blck_opts[plugins]"
    for v in "$plugs[@]"; do
        source $BLCK_HOME/plugins/$v/main.sh
    done
}