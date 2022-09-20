if ! [[ $ZSH_EVAL_CONTEXT =~ :file$ ]]; then
    # Script is NOT being sourced. Early exit
    echo -n "blck-sourcer: This script is not supposed to be run."
    echo " Please source it by using the keyword source or using . (dot)"
    return 1
fi

if [ -n "$BLCK_LOADED" ]; then
    echo -n "blck-sourcer: blck was already sourced into the current environment."
    echo -n " Sourcing it again can lead to unintentional and wierd behaviour. Do you still"
    echo " wish to continue? [Y|n] "
    read -q flag
    echo
    if [ $flag = 'n' ]; then
        return 2
    fi
fi 

BLCK_LOADED=true
source $BLCK_HOME/init.zsh