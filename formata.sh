#! /bin/bash

sudo uname -a
clear
printf "********************\n"
printf "USB Floppy Formatter for Linux - AKITASOFT 2021\n"
printf "********************\n\n"

if ! command -v ufiformat &>/dev/null; then
    printf "ufiformat could not be found, would you like me to help you install?\n"
    select yn in "Yes, help me install ufiformat" "No thank you!"; do
        case $yn in
        Yes*)
            printf ""
            printf "OK we will help you install...\n"
            helpme=1
            break
            ;;
        No*)
            printf "OK then... Goodbye!!\n"
            exit
            ;;
        esac
    done

    if helpme=1; then
        printf "Select package manager\n"
        select pm in "Apt (Debian/Ubuntu)" "DNF (Fedora/RHEL/Etc.)" "Yay (Arch/Manjaro)"; do
            case $pm in
            Apt*)
                sudo apt install ufiformat
                break
                ;;
            DNF*)
                sudo dnf install ufiformat
                break
                ;;
            Yay*)
                yay -S ufiformat
                break
                ;;
            esac
        done
    fi
fi

printf "ufiformat found, continuing...\n\n"
sleep .5
printf "**** Drives Avaialble ****\n"

diskselect=1
while diskselect=1; do
    usblist="$(sudo ufiformat -i | awk '$1 ~ /dev/ {print $1}')"
    sudo ufiformat -i

    printf "\nSelect Drive to Format: \n"
    select device in ${usblist[@]} "Refresh Devices"; do
        case $device in
        Refresh*)
            printf "Running udevadm trigger...\n"
            sudo udevadm trigger
            printf "Waiting while devices initialize...\n"
            sleep 10
            break
            ;;
        ${usblist[@]})
            formattypes=("1440" "1232" "1200" "720" "640")
            printf "\nSelect format type (Kb)\n"

            select format in ${formattypes[@]}; do
                printf ""
                break
            done

            printf "\nYou have selected $device to be formatted as a $format Kb floppy disk\n"
            printf "\n****************************************\n"
            printf "\n**** WARNING: ALL DATA WILL BE LOST ON SELECTED DISK PLEASE PROCEED WITH CAUTION ****\n"
            printf "\n****************************************\n\n"

            select yn in "Yes, I understand" "No!!! STOP!!!"; do
                case $yn in
                Yes*)

                    printf "\nOK you asked for it...\n"
                    formatme=1
                    break
                    ;;
                No*)
                    printf "\nOK then... Goodbye!!\n"
                    exit
                    ;;
                esac
            done

            if formatme=1; then
                printf "\nUnmounting if needed...\n\n"
                printf "\nRunning Format...\n\n"

                formatter="$(sudo ufiformat -f $format -v $device 2>&1)"
                echo $formatter
                if [[ $formatter = *'media type mismatch'* ]]; then
                    printf "\nMedia type error, please see that you are using the correct density disk...\n\n"
                    printf "\nExiting...\n"
                    exit
                fi

                printf "\nMaking Filesystem...\n\n"
                sudo mkfs.msdos $device
                sleep 10
                printf $'\a'
                exit

            fi
            ;;
            
        esac
    done
done
