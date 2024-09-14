#!/bin/sh

check_user_details() {
    echo "Are you sure you have configured your local git credentials?"
    read -p "If not you can configure now [Y/y]" ch
    if [[ $ch == "Y" || $ch == "y" ]]; then
        read -p "Enter your github email : " git_email
        read -p "Enter your gihub username : " git_username
        echo "Setting your git email and username....."
        sleep 2
        git config --global user.name "$git_username"
        git config --global user.email "$git_email"
        echo "Your credentails have been set successfully!!"
        sleep 1
    fi
}


function show_menu() {
    echo "============================================================"
    echo "                      Git Manager                           "
    echo "============================================================"
    echo "1. Let the git software know you have a project here!"
    echo "2. Check what git software is keeping track of!"
    echo "3. Did any changes in the project? Add files now!"
    echo "4. Want to commit the change you made? Commit now!"
    echo "5. Want to upload your project to GitHub?"
    echo "6. Get the latest version of the Cloud Repository!"
    echo "7. Want to Branch out and code?"
    echo "8. Exit Git manager"
    echo "=============================="
}

function read_choice() {
    read -p "Enter your choice [1-8]: " choice
    case $choice in
        1) initialize_repo ;;
        2) check_status ;;
        3) add_files ;;
        4) commit_changes ;;
        5) push_remote ;;
        6) pull_remote ;;
        7) branch_menu ;;
        8) echo "Exiting Git Manager. Goodbye!"; exit 0 ;;
        *) echo "Invalid choice. Please try ag{ain."; sleep 2 ;;
    esac
}

check_git_repo_status() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0  # Repo exists
    else
        return 1  # Repo does not exist
    fi
}

initialize_repo() {
    clear
    if check_git_repo_status; then
        echo "Git repository already initialized."
    else
        read -p "Do you want to initialize a git repo (locally) here? [Y/y]: " answer
        if [[ $answer == "Y" || $answer == "y" ]]; then
            git init > /dev/null 2>&1
            echo "Initialized empty Git repository."
        else
            echo "Git repository initialization aborted."
        fi
    fi
}


# Function to display Git status
check_status() {
    clear
    echo "Git status incoming...."
    sleep 1
    if ! git status > /dev/null 2>&1;then
        echo "Git repo not initialized here"
    else
        git status
    fi
}

add_files(){
    if ! check_git_repo_status; then
        echo "Git repo not initialized"
    else
        clear
        read -p "Do you want to add all files? [Y/y]" ch
        if [[ $ch == "Y" || $ch == "y" ]]; then
            echo "Adding all files to the staging area...."
            sleep 2
            git add .
            echo "Done adding all files to staging area"
        else
            clear
            echo "Here are the files in this directory"
            ls
            read -p "Choose which file you want to add to the staging area : " file_name
            echo "Adding $file_name to staging area"
            sleep 2
            git add "$file_name"
            echo "Added $file_name to the staging area."
        fi
    fi
}

commit_changes(){
if ! check_git_repo_status; then
    echo "Git repo not initialized"
else
    read -p "Do you want to commit the change? [y/Y]" ch
    if [[ $ch == "Y" || $ch == "y" ]]; then
        read -p "Enter the commit message : " commit_msg
        sleep 1
        echo "commiting....."
        git commit -m "$commit_msg"
        echo "Changes commited"
    fi
fi
}

branch_menu() {
   echo "Welcome to branch operations"
   show_branch_operations
   read -p "Enter your choice : [1-3]"
}


show_branch_operations() {
while true; do
    echo "1. Show current Branch"
    echo "2. Shift to another Branch"
    echo "3. Create another Branch"
    echo "4. List branches"
    echo "5. Exit branch operations"
    read -p "Enter your choice [1-3]: " choice
    case $choice in
    1) show_current_branch;;
    2) shift_branch;;
    3) create_branch;;
    4) list_branches;;
    5) echo "Exiting branch operations...."; clear; show_menu; read_choice;;
    *) echo "Invalid choice";;
    esac
done
}

list_branches() {
clear
    git branch
}

show_current_branch() {
clear
    echo " $(git branch | grep "*") is your current branch"
    sleep 3
}

shift_branch() {
clear
    git branch
    read -p "enter branch you want to shift to : " branch_name
    git checkout "$branch_name"
}

create_branch() {
clear
    read -p "Enter branch name to create : " create_name
    git branch "$create_name"
    echo "Branch $create_name created!"
}
