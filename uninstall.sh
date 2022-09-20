IDENTIFIER="# blck Configuration (b336b5ce9b1143e372019e2667d846df)"
END_IDENTIFIER="# End of blck Configuration (1d484a24ce09a4c943b76af8a09b2e26)"

uninstall() {
    txt=$(eval sed \'/$IDENTIFIER\.\*\$/,/$END_IDENTIFIER\.\*\$/\{d\}\' $HOME/\.zshrc)
    echo "$txt" > $HOME/.zshrc
}

is_installed() {
    txt=$(eval sed -n \'/$IDENTIFIER\.\*\$/,/$END_IDENTIFIER\.\*\$/\{p\}\' $HOME/\.zshrc)
    if [ -z "$txt" ]; then
        return 1
    else
        return 0
    fi
}

is_installed && uninstall && echo "Uninstalled blck. It is recommended to restart your shell." || echo "\033[31mERROR\033[0m blck.uninstall: No identifiable blck installation found, you may have to uninstall it manually."