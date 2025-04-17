#!/bin/bash

LOG_FILE="/var/log/samba/scan.log"
SHARE_DIR="/usr/local/safesamba/shares"

function show_menu(){
date
echo "   |--------------------------------------------------------------------|"
echo "   | :::.. SafeSamba SecureFileserver ..:::                             |"
echo "   |--------------------------------------------------------------------|"
echo "   | #  USer Man.  | # Share Man.    | # Logs/Reports                   |"
echo "   | -------------------------------------------------------------------|"
echo "   | 1.Add User    | 11.Create Share | 20.View Logs                     |"
echo "   | 2.Delete User | 12.Remove Share | 21.Quarantine Files              |"
echo "   | 3.User List   | 13.Share List   | 22.Scan Service Status           |"
echo "   |--------------------------------------------------------------------|"
echo "   | 99.Exit                                                            |"
echo "   |--------------------------------------------------------------------|"
}

add_user() {
    NEW_USER=$(whiptail --inputbox "Enter The New UserName:" 10 40 3>&1 1>&2 2>&3)
    if [[ -n "$NEW_USER" ]]; then
        useradd -m -s /sbin/nologin "$NEW_USER"
        smbpasswd -a "$NEW_USER"
        whiptail --msgbox "User $NEW_USER Created" 10 40
    fi
}

delete_user() {
    DEL_USER=$(whiptail --inputbox "Enter The Name of The User to be Deleted:" 10 45 3>&1 1>&2 2>&3)
    if [[ -n "$DEL_USER" ]]; then
        smbpasswd -x "$DEL_USER"
        userdel -r "$DEL_USER"
        whiptail --msgbox "User $DEL_USER deleted." 10 40
    fi
}

list_users() {
    USERS=$(pdbedit -L | cut -d: -f1)
    whiptail --msgbox "Samba Kullanıcıları:\n$USERS" 20 60
}

create_share() {
SHARE_NAME=$(whiptail --inputbox "Share Name:" 8 40 3>&1 1>&2 2>&3)
#[ -z "$SHARE_NAME" ] && bash mainmenu.sh
pdbedit -L | cut -d: -f1 | tr ' ' '\n' | sed '/^$/d' > /tmp/userlist

USER_ENTRIES=()
    while read -r user; do
            USER_ENTRIES+=("$user" "" OFF)  # UserName + Blank Desc. + Default OFF
    done < /tmp/userlist
    
SELECTED_USERS=$(whiptail --title "Select Users" --checklist "Select Users:" 20 60 10 "${USER_ENTRIES[@]}" 3>&1 1>&2 2>&3)
SELECTED_USERS=$(echo "$SELECTED_USERS" | tr -d '"')

SHARE_PATH="$SHARE_DIR/$SHARE_NAME"
mkdir -p "$SHARE_PATH"
chmod 770 "$SHARE_PATH"
#chown root:"$SHARE_NAME" "$SHARE_PATH"
chown root:smbusers "$SHARE_PATH"

echo "[$SHARE_NAME]" >> /etc/samba/smb.conf
echo "    path = $SHARE_PATH" >> /etc/samba/smb.conf
echo "    valid users = $SELECTED_USERS" >> /etc/samba/smb.conf
echo "    read only = no" >> /etc/samba/smb.conf
echo "    guest ok = no" >> /etc/samba/smb.conf
echo "    create mask = 0660" >> /etc/samba/smb.conf
echo "    directory mask = 0770" >> /etc/samba/smb.conf

systemctl restart smbd
whiptail --msgbox "{$SHARE_NAME} Share Created" 7 30
}

delete_share() {
    DEL_SHARE=$(whiptail --inputbox "Enter the name of the Share:" 10 40 3>&1 1>&2 2>&3)
    if [[ -n "$DEL_SHARE" ]]; then
        rm -rf "$SHARE_DIR/$DEL_SHARE"
        whiptail --msgbox "Share $DEL_SHARE deleted." 10 40
    fi
}

list_share() {
    SHARES=$(ls "$SHARE_DIR")
    whiptail --msgbox "Share List:\n$SHARES" 20 60
}

view_logs() {
    LOG_FILE="/var/log/samba/scan.log"

    if [[ -s "$LOG_FILE" ]]; then
        dialog --title "Samba Log Records" --textbox "$LOG_FILE" 40 145
    else
        whiptail --msgbox "Log File Not Found or Log File is Empty" 10 40
    fi
    clear
}

function read_input(){
tput setaf 4
local c
read -p "You can choose from the menu numbers: " c
tput sgr0
case $c in
1) add_user ;;
2) delete_user ;;
3) list_users ;;
11) create_share ;;
12) delete_share ;;
13) list_share ;;
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
