#!/bin/sh

source "$(pwd)/helper.sh"
check_user_details
while true; do
    clear
    show_menu
    read_choice
    echo "Press Enter to continue..."
    read
done
