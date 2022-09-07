declare -g -A __blck_opts

blck.config.read-blckrc () {
    config="$(cat ~/.blckrc | sed -n 's/^\s*\([0-9A-Za-z\-]*\)\s*=\s*\([^ #]*\).*$/\1:\2/p')"
    echo "$config" | while IFS=':' read -r k v; do
        __blck_opts[$k]="$v"
    done
}

blck.config.change-blckrc() {
    new_config="$(cat ~/.blckrc | sed -n 's/^\(\s*\)\([0-9A-Za-z\-]*\)\(\s*=\s*\)\([^ #]*\)\(.*\)$/\1'""$1""'\3'""$2""'\5/')"
    echo $new_config > ~/.blckrc
}