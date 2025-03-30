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

# CTRL+C, CTRL+Z
trap '' SIGINT SIGQUIT SIGTSTP

while true
do
clear
show_menu
done
