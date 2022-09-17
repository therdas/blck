#!/usr/bin/zsh
ACCENT='#F35C04'
GRAY='#888888'
LGRAY="#9F9F9F"
# Menu Chooser
function menu() {
    if [ $silent -eq 0 ]; then
        printf -v $1 1; return
    fi

    tput civis
    opts=(${@:2})

    go-up() {
        mcount=$1
        for i in $(seq 1 $mcount); do
            tput cuu1
        done
    }

    go-down() {
        mcount=$1
        for i in $(seq 1 $mcount); do
            tput cud1
        done
    }

    highlight() {
        i=$1
        print -n "\r"
        tput el
        print -Pn "%F{$ACCENT}%B › $opts[$i]%b%f"
    }
    unhighlight() {
        i=$1
        print -n "\r"
        tput el
        print -Pn " › $opts[$i]"
    }

    # then print -P " › %F{$ACCENT}%B$o%b%k" # mark & highlight the current option
    escape_char=$(printf "\u1b")
    enter_char=$(printf "\u0A")
    index=1
    count=0
    for i in "${@:2}"; do
        count=$(($count + 1))
        print -P " › $i"
    done
    print -P "%F{$LGRAY}   ⇅ to choose, → or ↲ to accept%f"
    go-up 1
    go-up $count
    highlight 1

    

    while true; do
        read -rsk1 mode # get 1 character
        if [[ $mode == $escape_char ]]; then
            read -rsk2 mode # read 2 more chars
        elif [[ $mode == "
" ]]; then
            diff=$(($count - $index + 1))
            go-down $diff
            print -n "\r"
            tput el
            tput cnorm
            printf -v $1 $index
            return
        else
            echo "\n\n\n\n:>><$mode>"
        fi
        case $mode in
            '[A') 
                if [ $index -gt 1 ]; then
                    unhighlight $index
                    index=$(($index - 1))
                    go-up 1
                    highlight $index
                fi 
                ;;
            '[B')
                if [ $index -lt $count ]; then
                    unhighlight $index
                    index=$(($index + 1))
                    go-down 1
                    highlight $index
                fi
                ;;
            '[C') 
                diff=$(($count - $index + 1))
                go-down $diff
                print -n "\r"
                tput el
                tput cnorm
                printf -v $1 $index
                return
                ;;
            *) ;;
        esac
    done
}

silent=1
if [ $# -eq 1 ]; then
    if [ $1 = "-q" ]; then
        silent=0
    fi
fi


header() {
    \clear
    print -P "%F{$ACCENT}     ______     __         ______     __  __    
    /\\\\  == \\\\   /\\\\ \\\\       /\\\\  ___\\\\   /\\\\ \\\\/ /    
    \\\\ \\\\  __<   \\\\ \\\\ \\\\____  \\\\ \\\\ \\\\____  \\\\ \\\\  _\"-.  
     \\\\ \\\\_____\\\\  \\\\ \\\\_____\\\\  \\\\ \\\\_____\\\\  \\\\ \\\\_\\\\ \\\\_\\\\ 
      \\\\/_____/   \\\\/_____/   \\\\/_____/   \\\\/_/\\\\/_/ %f"
    echo 
    print -P "🧙 %F{$ACCENT}%BBLCK Setup Wizard%b%f ✨"
    cat VERSIONS | head -n 1
    print -P "%F{$GRAY}Run \`blck changelog\` after installing to see the changelog%f"
    echo
}
if [ $silent -ne 0 ]; then
    header
    selections=(
        'Automagic Configuration'
        'Manual Configuration'
    )
    echo "How do you want to configure BLCK?" 
fi
menu res "${selections[@]}"

if [ $res -eq 1 ]; then
    cp payload/default_blckrc ~/.blckrc
elif [ $res -eq 2 ]; then
    while true; do
        print -Pn "\n %F{$ACCENT}■%f Building .blckrc
 ────────────────── \n \n"
    
        print -P " What %F{$ACCENT}theme%f do you want? "
        selections=()
        for file in "themes/"*".zsh-theme"; do
            selections+="$(basename $file '.zsh-theme')"
        done 
        menu res "${selections[@]}"
        tname="$selections[res]"


        source themes/$tname.zsh-theme
        pdump() {
        local collist=($(echo "$@"))
        local v=0
            for i in "${collist[@]:1:4}"; do
                v=$((v+1))
                echo -n "%K{$i}  %k"
            done
        }
    
        print -P "\n Which %F{$ACCENT}theme palette%f do you want to use? "
        selections=()
        for i in $(seq 1 $#palettes); do
            selections+="$i $(pdump $palettes[$i]) $palette_aliases[$i] "
        done
        menu res "${selections[@]}" 
        palname="$res"

        plugins=()
        print -P "\n Which %F{$ACCENT}plugins%f do you want? "
        selections=()
        for file in "plugins/"*"/"; do
            selections+=$(basename $file)
        done
        selections+="Done (Close Menu)"
        while true; do
            tput sc
            menu res "${selections[@]}"
            if [ "$res" -eq "$#selections" ]; then
                break
            fi
            plugins+="$selections[$res]"
            selections=("${(@)selections[1,$res-1]}" "${(@)selections[$res+1,$#selections]}")
            tput rc
        done
        print -Pn "\n The following plugins were chosen, and will be loaded in this order: \n"
        count=1
        pname=""
        for i in "$plugins[@]"; do 
            print -Pn "  %F{$ACCENT}$count%f $i\n"
            count=$((count + 1))
            pname="$pname,$i"
        done
        pname="${pname:1}"

        print -Pn "\n Do you wish to include any %F{$ACCENT}plugin specific%f settings? [Y|n] "
        read -q flag
        if [ "$flag" = "y" ]; then
            print -P "\n Enter the values below, as %Bkey%b%F{$ACCENT} = %f%Uvalue%u pairs. Seperate each pair by newlines. To stop, press %F{$ACCENT}#%f"
            read -r -d'#' args
            print -P "\n The following arguments will be appended to your blckrc file:\n$args"
        fi

        print -P "\n\n %BThe following .blckrc file was generated:%b"
        print -P "%F{$GRAY}   blck standard header %f
 # Generated by blck Installer

 theme = $tname
 theme-palette = $palname
 plugins = $pname

 # Plugin Arguments

 $args

 # End of Generation
        "
        print -Pn " %F{$LGRAY}Choosing N will require you to go through the setup process %F{red}again%f.%f"
        print -Pn " \nWrite file to $HOME/.blckrc? [Y|n] "
        read -q flag
        if [ "$flag" = "y" ]; then
            break
        fi
    done
    
    #Write to file 
    echo '
#===================================================#
#       BLCKrc - BLCK Theme Framework Config        #
#===================================================#
# Format: As long as a option `opt` is valid, the   #
#         syntax is simple, just                    #    
#                                                   #
#         opt=value                                 #
#                                                   #
#         The values should NOT be quoted.          #
#                                                   #
#         Comments are preceeded with an #          #
#         NO SPACES in the value                    #
#         Denote multiple values with ,             #
#         Eg: plugins = syntax-highlighting,updater #
#                                                   #
# For syntax highlighting, use your editor''s high-   #
# lighter for shell scripts, that should be enough  #
#                                                   #
# Will switch later to AskJSON (shhh)               #
#---------------------------------------------------#

# Generated by blck Installer
'"
theme = $tname
theme-palette = $palname

plugins = $pname

$args
# End of Generation

    " > $HOME/.blckrc
echo
fi

echo "


#__322209919_BLCKINSTUNINSTIDENTIFIER Do not modify anything on this line or the next! This will prevent
#proper uninstallation and/or updation of blck. This identifier was made by blck.

#-------------------------------------#
# blck Configuration - Autogenerated  #
#-------------------------------------#

BLCK_HOME="/home/therdas/.blck"
[ ! -e "$BLCK_HOME/blck.sh" ] || source $BLCK_HOME/blck.sh
[ ! -e "$BLCK_HOME/blck.sh" ] && echo "Could not locate blck. Please clean up your .zshrc file."

#-------------------------------------#
#__END_322209919_BLCKINSTUNINSTIDENTIFIER You can continue after this line
" >> ~/.zshrc

if [ $silent -eq 1 ]; then
    print -P "\n\n Your %F{$ACCENT}blck%f installation is ready to go! Just restart your shell to load it.%f"
fi

tput cnorm