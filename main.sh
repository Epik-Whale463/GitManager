#!/bin/bash

# Source the helper script
. "$(dirname "$0")/helper.sh"

# Main function
check_git_installed
check_user_details
while true; do
    show_menu
    read_choice
done
