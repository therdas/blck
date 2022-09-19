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
    cat CHANGELOG | head -n 1
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
    cp ${0:A:h}/payload/default_blckrc ~/.blckrc
    echo "motd-file = ${0:A:h}/payload/motd.txt" >> ~/.blckrc
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
        print -Pn " %F{$LGRAY}Choosing no will require you to go through the setup process %F{red}again%f.%f"
        print -Pn " \n Write file to $HOME/.blckrc? [Y|n] "
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

# CODE DUPLICATION
# Copied from uninstall.sh

IDENTIFIER="# blck Configuration (b336b5ce9b1143e372019e2667d846df)"
END_IDENTIFIER="# End of blck Configuration (1d484a24ce09a4c943b76af8a09b2e26)"

uninstall() {
    txt=$(eval sed \'/$IDENTIFIER\.\*\$/,/$END_IDENTIFIER\.\*\$/\{d\}\' $HOME/\.zshrc)
    cp $HOME/.zshrc `pwd`/.zshrc-backup
    print -P "%F{$GRAY} Making a backup of your .zshrc at "`pwd`"/.zshrc-backup%f"
    echo "$txt" > $HOME/.zshrc
}

is_installed() {
    txt=$(eval sed -n \'/$IDENTIFIER\.\*\$/,/$END_IDENTIFIER\.\*\$/\{p\}\' $HOME/\.zshrc)
    if [ -z "$txt" ]; then
        previous_install=1
    else
        previous_install=0
    fi
}

# END OF CODE DUPLICATION <- this is so that i can fix this later :)
inst_zshrc=0
is_installed

if [ $previous_install -eq 0 -a $silent -eq 1 ] ; then
    print -P "\n %F{yellow}Warning%f We found a previous installation of blck in your .zshrc folder. Do you want us to remove it and install it anew?"
    selections=(
        'Yes (Recommended)'
        'Show me what you'"'"'ll remove first'
        'No (Can cause some weird issues)'
    )
    menu res "$selections[@]"
    echo
    if [ $res -eq 1 ]; then
        uninstall
        echo " Removed previous blck installation from your .zshrc!"
    elif [ $res -eq 2 ]; then
        print -P "\n %BThis is what we'll be removing:%b"
        print -P "\n%F{white}%K{#333333}$txt%k%f\n"
        echo -n " Do you want us to remove this? [Y|n]"
        read -q flag
        echo
        if [ $flag = 'y' ]; then
            uninstall
            echo " Removed previous blck installation from your .zshrc!"
        else
            inst_zshrc = 1
        fi
    else 
        inst_zshrc = 1
    fi
fi

is_installed

if [ $previous_install -eq 0 -a $silent -eq 0 ]; then
    inst_zshrc=1
fi

[ $inst_zshrc -eq 0 ] && echo "

  # blck Configuration (b336b5ce9b1143e372019e2667d846df)
  # Modifying the previous line ⬆ will prevent blck from uninstalling
  # itself. If you include anything between them, they'll be removed
  # by the uninstaller as well.

  BLCK_HOME="${0:A:h}"
  [ ! -e ${0:A:h}/blck.zsh ] || source ${0:A:h}/blck.zsh
  [ ! -e ${0:A:h}/blck.zsh ] && echo \"Could not locate blck. Please clean up your .zshrc file.\"
                                                               
  # Don't edit this line as well ⬇
  # End of blck Configuration (1d484a24ce09a4c943b76af8a09b2e26)

" >> ~/.zshrc

if [ $silent -eq 1 ]; then
    print -P "\n Your %F{$ACCENT}blck%f installation is ready to go! Just restart your shell to load it.%f"
fi

tput cnorm