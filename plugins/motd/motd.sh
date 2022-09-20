print-motd() {
    print -P $(eval cat $1)
}