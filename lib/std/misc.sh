blck.std.misc.clear-to-bottom() {
    \clear
    echo "$(( $(tput lines) - $__blck_lines + 1 )) <<"
    printf '\n%.0s' {1..$(( $(tput lines) - $__blck_lines + 1 ))}
}