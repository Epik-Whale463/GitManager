#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if git is installed
check_git_installed() {
    if ! command -v git &> /dev/null; then
        print_color "$RED" "Git is not installed. Please install Git and try again."
        exit 1
    fi
}

# Function to check user details
check_user_details() {
    print_color "$YELLOW" "Checking your Git configuration..."
    local git_name=$(git config --global user.name)
    local git_email=$(git config --global user.email)

    if [[ -z "$git_name" || -z "$git_email" ]]; then
        print_color "$YELLOW" "Your Git credentials are not fully configured."
        configure_git_credentials
    else
        print_color "$GREEN" "Your Git credentials are already configured:"
        echo "Name: $git_name"
        echo "Email: $git_email"
        read -p "Would you like to re-configure them now? [Y/n]: " ch
        if [[ $ch == "Y" || $ch == "y" || $ch == "" ]]; then
            configure_git_credentials
        fi
    fi
    clear
}

configure_git_credentials() {
    read -p "Enter your GitHub username: " git_username
    read -p "Enter your GitHub email: " git_email
    print_color "$BLUE" "Setting your Git email and username..."
    git config --global user.name "$git_username" &> /dev/null
    git config --global user.email "$git_email" &> /dev/null
    print_color "$GREEN" "Your credentials have been set successfully!"
}

# Function to show menu
show_menu() {
    clear
    echo "You are at: $(pwd)"
    print_color "$GREEN" "============================================================"
    print_color "$GREEN" "                 Welcome to Git Manager!                    "
    print_color "$GREEN" "        Your friendly guide to version control              "
    print_color "$GREEN" "============================================================"
    echo
    print_color "$YELLOW" "Getting Started:"
    echo "0. Manage .gitignore (Hide specific files/folders from Git)"
    echo "1. Create a new project (Initialize a Git repository)"
    echo "2. See what's changed in your project (Check status)"
    echo
    print_color "$YELLOW" "Saving Your Work:"
    echo "3. Prepare files for saving (Add to staging area)"
    echo "4. Save your changes (Commit)"
    echo
    print_color "$YELLOW" "Collaborating with Others:"
    echo "5. Send your changes to GitHub (Push)"
    echo "6. Get the latest updates from GitHub (Pull)"
    echo
    print_color "$YELLOW" "Advanced Features:"
    echo "7. Work on different versions of your project (Manage branches)"
    echo
    print_color "$YELLOW" "Other Options:"
    echo "8. Exit Git Manager"
    echo
    print_color "$BLUE" "============================================================"
    echo
    print_color "$YELLOW" "What would you like to do? (Enter a number 0-8)"
}

# Function to read user choice
read_choice() {
    read -p "Enter your choice [0-8]: " choice
    case $choice in
        0) manage_gitignore ;;
        1) initialize_repo ;;
        2) check_status ;;
        3) add_files ;;
        4) commit_changes ;;
        5) push_to_remote ;;
        6) pull_remote ;;
        7) branch_menu ;;
        8) print_color "$GREEN" "Exiting Git Manager. Goodbye!"; exit 0 ;;
        *) print_color "$RED" "Invalid choice. Please try again."; sleep 2 ;;
    esac
}

# Function to manage .gitignore
manage_gitignore() {
    clear
    print_color "$BLUE" "The .gitignore file hides specific folders/files from Git tracking."
    echo ""
    print_color "$YELLOW" "Current files in this folder:"
    ls -1A
    
    echo ""
    read -p "$(print_color "$GREEN" "Enter the name of the file/folder to add to .gitignore (or 'q' to quit): ")" item

    while [[ $item != "q" ]]; do
        if grep -Fxq "$item" .gitignore 2>/dev/null; then
            print_color "$YELLOW" "$item is already in .gitignore."
        else
            echo "$item" >> .gitignore
            print_color "$GREEN" "$item has been added to .gitignore."
        fi
        read -p "$(print_color "$GREEN" "Enter another file/folder (or 'q' to quit): ")" item
    done
}

# Function to check if current directory is a Git repository
check_git_repo_status() {
    if git rev-parse --is-inside-work-tree &> /dev/null; then
        return 0  # Repo exists
    else
        return 1  # Repo does not exist
    fi
}

# Function to initialize a new Git repository
initialize_repo() {
    clear
    if check_git_repo_status; then
        print_color "$YELLOW" "A Git repository is already initialized in this directory."
    else
        print_color "$YELLOW" "This will create a new Git repository in the current directory."
        read -p "Do you want to proceed? [Y/n]: " answer
        if [[ $answer == "Y" || $answer == "y" || $answer == "" ]]; then
            git init &> /dev/null
            print_color "$GREEN" "Initialized empty Git repository in $(pwd)/.git/"
        else
            print_color "$YELLOW" "Git repository initialization aborted."
        fi
    fi
    read -p "Press Enter to continue..."
}

# Function to display Git status
check_status() {
    clear
    print_color "$BLUE" "Checking Git status..."
    if ! check_git_repo_status; then
        print_color "$RED" "This directory is not a Git repository."
    else
        git status > status.txt
        python3 llm.py status.txt &> /dev/null
        if [ -f response.txt ]; then
            cat response.txt
            rm response.txt
        else
            print_color "$RED" "Failed to generate status summary. Here's the raw status:"
            cat status.txt
        fi
        rm status.txt
    fi
    echo ""
    read -p "Press Enter to continue..."
}

# Function to add files to staging area
add_files() {
    if ! check_git_repo_status; then
        print_color "$RED" "This directory is not a Git repository."
    else
        clear
        print_color "$YELLOW" "Do you want to:"
        echo "1. Add all files"
        echo "2. Add specific files"
        read -p "Enter your choice [1-2]: " ch
        case $ch in
            1)
                print_color "$BLUE" "Adding all files to the staging area..."
                git add . &> /dev/null
                print_color "$GREEN" "All files have been added to the staging area."
                ;;
            2)
                clear
                print_color "$BLUE" "Files in this directory:"
                ls -1A
                echo
                read -p "Enter the name of the file you want to add (or 'q' to quit): " file_name
                while [[ $file_name != "q" ]]; do
                    if [[ -e "$file_name" ]]; then
                        git add "$file_name" &> /dev/null
                        print_color "$GREEN" "Added $file_name to the staging area."
                    else
                        print_color "$RED" "File/directory $file_name not found."
                    fi
                    read -p "Enter another file name (or 'q' to quit): " file_name
                done
                ;;
            *)
                print_color "$RED" "Invalid choice."
                ;;
        esac
    fi
    read -p "Press Enter to continue..."
}

# Function to commit changes
commit_changes() {
    if ! check_git_repo_status; then
        print_color "$RED" "This directory is not a Git repository."
    else
        clear
        git status --short
        read -p "Do you want to commit the changes? [Y/n]: " ch
        if [[ $ch == "Y" || $ch == "y" || $ch == "" ]]; then
            read -p "Enter a commit message: " commit_msg
            if git commit -m "$commit_msg" &> /dev/null; then
                print_color "$GREEN" "Changes committed successfully."
            else
                print_color "$RED" "Failed to commit changes. Make sure you have staged files to commit."
            fi
        else
            print_color "$YELLOW" "Commit aborted."
        fi
    fi
    read -p "Press Enter to continue..."
}

# Function to check remote configuration and push changes
push_to_remote() {
    if ! check_git_repo_status; then
        print_color "$RED" "This directory is not a Git repository."
        read -p "Press Enter to continue..."
        return
    fi

    clear
    print_color "$YELLOW" "Preparing to push changes to remote repository..."

    # Check if 'origin' remote is set up and has a valid URL
    if ! git remote -v | grep "http"; then
        print_color "$RED" "No remote repository is set up."
        read -p "$(print_color "$YELLOW" "Do you want to add a remote repository now? [Y/n]: ")" add_remote
        if [[ $add_remote == "Y" || $add_remote == "y" || $add_remote == "" ]]; then
            read -p "$(print_color "$GREEN" "Enter the URL of your remote repository: ")" url

            if git remote get-url origin &> /dev/null; then
                print_color "$YELLOW" "Remote 'origin' already exists. Do you want to update the URL? [Y/n]: "
                read update_remote
                if [[ $update_remote == "Y" || $update_remote == "y" || $update_remote == "" ]]; then
                    git remote set-url origin "$url"
                    if [ $? -eq 0 ]; then
                        print_color "$GREEN" "Remote repository URL updated successfully."
                        sleep 2
                    else
                        print_color "$RED" "Failed to update remote repository URL. Please check the URL and try again."
                        read -p "Press Enter to continue..."
                        return
                    fi
                else
                    print_color "$YELLOW" "Push aborted. You need to update the remote repository URL."
                    read -p "Press Enter to continue..."
                    return
                fi
            else
                git remote add origin "$url"
                if [ $? -eq 0 ]; then
                    print_color "$GREEN" "Remote repository added successfully."
                    sleep 2
                else
                    print_color "$RED" "Failed to add remote repository. Please check the URL and try again."
                    read -p "Press Enter to continue..."
                    return
                fi
            fi
        else
            print_color "$YELLOW" "Push aborted. You need to set up a remote repository first."
            read -p "Press Enter to continue..."
            return
        fi
    fi

    # Check current branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$current_branch" ]; then
        print_color "$RED" "Unable to determine current branch. Please check your repository."
        read -p "Press Enter to continue..."
        return
    fi

    # Confirm pushing changes
    read -p "$(print_color "$YELLOW" "Do you want to push changes to remote repository now? [Y/n]: ")" push_now
    if [[ $push_now == "Y" || $push_now == "y" || $push_now == "" ]]; then
        print_color "$BLUE" "Pushing changes to remote repository..."
        if git push -u origin "$current_branch" &> /dev/null; then
            print_color "$GREEN" "Changes pushed to remote repository successfully."
        else
            print_color "$RED" "Failed to push changes. This could be due to several reasons:"
            echo "1. No internet connection"
            echo "2. Remote repository doesn't exist"
            echo "3. You don't have permission to push to this repository"
            echo "4. Remote contains work that you don't have locally"
            
            read -p "$(print_color "$YELLOW" "Would you like to try pulling changes from remote first? [Y/n]: ")" pull_first
            if [[ $pull_first == "Y" || $pull_first == "y" || $pull_first == "" ]]; then
                if git pull origin "$current_branch" &> /dev/null; then
                    print_color "$GREEN" "Successfully pulled changes. Attempting to push again..."
                    if git push -u origin "$current_branch" &> /dev/null; then
                        print_color "$GREEN" "Changes pushed to remote repository successfully."
                    else
                        print_color "$RED" "Push failed again. Please check your repository permissions and try again later."
                    fi
                else
                    print_color "$RED" "Failed to pull changes. Please resolve conflicts manually and try pushing again."
                fi
            else
                print_color "$YELLOW" "Push aborted. Please resolve the issues and try again."
            fi
        fi
    else
        print_color "$YELLOW" "Push aborted. You can push changes later."
        read -p "Press Enter to continue..."
    fi
}





# Function to pull changes from remote repository
pull_remote() {
    if ! check_git_repo_status; then
        print_color "$RED" "This directory is not a Git repository."
    else
        clear
        print_color "$YELLOW" "Pulling changes from remote repository..."
        if git pull &> /dev/null; then
            print_color "$GREEN" "Successfully pulled changes from remote repository."
        else
            print_color "$RED" "Failed to pull changes. This could be due to:"
            echo "1. No internet connection"
            echo "2. Conflicts with local changes"
            echo "3. No remote repository configured"
            print_color "$YELLOW" "Please check your connection and repository configuration."
        fi
    fi
    read -p "Press Enter to continue..."
}

# Function to show branch menu
branch_menu() {
    while true; do
        clear
        print_color "$BLUE" "Branch Operations"
        echo "1. Show current branch"
        echo "2. Switch to another branch"
        echo "3. Create a new branch"
        echo "4. List all branches"
        echo "5. Return to main menu"
        read -p "Enter your choice [1-5]: " choice
        case $choice in
            1) show_current_branch ;;
            2) switch_branch ;;
            3) create_branch ;;
            4) list_branches ;;
            5) break ;;
            *) print_color "$RED" "Invalid choice." ; sleep 2 ;;
        esac
    done
}

# Function to show current branch
show_current_branch() {
    clear
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$current_branch" ]; then
        print_color "$GREEN" "Current branch: $current_branch"
    else
        print_color "$RED" "Unable to determine current branch. Please check your repository."
    fi
    read -p "Press Enter to continue..."
}

# Function to switch branch
switch_branch() {
    clear
    print_color "$BLUE" "Available branches:"
    git branch
    echo
    read -p "Enter the name of the branch you want to switch to: " branch_name

    # Check if the branch exists
    if git show-ref --verify --quiet refs/heads/"$branch_name"; then
        if git checkout "$branch_name" &> /dev/null; then
            print_color "$GREEN" "Switched to branch '$branch_name'"
        else
            print_color "$RED" "Failed to switch branch. Please check for uncommitted changes or other issues."
        fi
    else
        print_color "$RED" "Branch '$branch_name' does not exist. Please check the branch name."
    fi
    read -p "Press Enter to continue..."
}


# Function to create a new branch
create_branch() {
    clear
    read -p "Enter the name for the new branch: " new_branch
    
    # Create the new branch
    if git branch "$new_branch" &> /dev/null; then
        print_color "$GREEN" "Branch '$new_branch' created."
        
        # Ask if the user wants to switch to the new branch
        read -p "Do you want to switch to the new branch? [Y/n]: " switch
        if [[ $switch == "Y" || $switch == "y" || $switch == "" ]]; then
            if git checkout "$new_branch" &> /dev/null; then
                print_color "$GREEN" "Switched to branch '$new_branch'"
            else
                print_color "$RED" "Failed to switch to the new branch."
            fi
        fi
    else
        print_color "$RED" "Failed to create branch '$new_branch'. It may already exist."
    fi
    
    # Prompt to continue
    read -p "Press Enter to continue..." 
}


# Function to list all branches
list_branches() {
    clear
    print_color "$BLUE" "All branches:"
    git branch -a
    read -p "Press Enter to continue..."
}
