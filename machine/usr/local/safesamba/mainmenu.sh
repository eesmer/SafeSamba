#!/bin/bash

function show_menu(){
date
echo "   |--------------------------------------------------------------------|"
echo "   | :::.. SafeSamba SecureFileserver ..:::                             |"
echo "   |--------------------------------------------------------------------|"
echo "   | #  USer Man.  | Share Man.      | Logs/Reports                     |"
echo "   | -------------------------------------------------------------------|"
echo "   | 1.Add User    | 11.New Share    | 20.View Logs                     |"
echo "   | 2.Delete User | 12.Remove Share | 21.Quarantine Files              |"
echo "   | 3.User List   | 13.Share List   | 22.Scan Service Status           |"
echo "   |--------------------------------------------------------------------|"
echo "   | 99.Exit                                                            |"
echo "   |--------------------------------------------------------------------|"
}

add_user() {
    NEW_USER=$(whiptail --inputbox "Enter The New UserName:" 10 40 3>&1 1>&2 2>&3)
    if [[ -n "$NEW_USER" ]]; then
        sudo useradd -m -s /sbin/nologin "$NEW_USER"
        sudo smbpasswd -a "$NEW_USER"
        whiptail --msgbox "User $NEW_USER Created" 10 40
    fi
}

function read_input(){
tput setaf 4
local c
read -p "You can choose from the menu numbers: " c
tput sgr0
case $c in
99) add_user ;;
99) exit 0 ;;
*)
tput setaf 1
echo "Please select from the menu numbers"
tput sgr0
pause
esac
}

# CTRL+C, CTRL+Z
trap '' SIGINT SIGQUIT SIGTSTP

while true
do
clear
show_menu
read_input
done
