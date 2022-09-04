blck.misc.clear() {
    printf '\n%.0s' {1..$(( $(tput lines) - $__blck_lines + 1 ))}
}