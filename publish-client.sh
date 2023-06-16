#!/bin/bash

# Clear the screen
clear

# Check if the script is running in a directory named "client"
if [ "$(basename "$PWD")" != "client" ]; then
    # Set text color to red
    tput setaf 1
    echo "Error: You should be in the client directory. Run: cd client"
    tput sgr0  # Reset text color
    exit 1
fi

# Check if package.json exists in the current directory
if [ ! -f package.json ]; then
    # Set text color to red
    tput setaf 1
    echo "Error: No package.json found"
    tput sgr0  # Reset text color
    exit 1
fi


# Function to get version from package.json
get_version() {
    grep '"version"' package.json | cut -d '"' -f4
}

get_name() {
    grep '"name"' package.json | cut -d '"' -f4
}

write_commands() {
    local NEW_VERSION=$(get_version)
    local CURRENT_BRANCH=$(git branch --show-current)

    # Change color to green
    tput setaf 2
    echo "You are on the branch now: ${CURRENT_BRANCH}, and this will be the client's new version: ${NEW_VERSION}. So, you will publish this branch by these commands."
    tput sgr0  # Reset color

    echo "You can run these commands now in the same order for publishing the client:"
    echo
    echo "------------------------------------------------------------------------------------"
    echo

    echo "git add ."
    echo "git commit -m\"Client's version has been bumped to: ${NEW_VERSION}\""
    echo "git tag client-${NEW_VERSION}"
    echo "git push"
    echo "git push origin client-${NEW_VERSION}"

    echo
    echo "------------------------------------------------------------------------------------"
    echo
}


# Check if there are uncommitted changes
if [[ -z $(git status --porcelain) ]]; then
    # No changes
    echo "Code base is clean, no uncommitted changes found."
    echo
    echo "------------------------------------------------------------------------------------"
    echo
else
    # Changes
    tput setaf 1
    echo "Sorry, but your branch contains uncommitted code. Before proceeding, you need to commit all changes."
    echo "Publishing a new version without committing ensures that the version control system accurately reflects the state of the code for that particular version."
    echo "It also helps to maintain the integrity of your codebase and avoids confusion or mistakes in future."
    tput setaf 2
    echo "You should run 'git status' to see uncommitted files."
    tput setaf 1
    echo "Please commit your changes and try again. Exiting..."
    tput sgr0
    exit 1
fi

# Ask user for the branch to checkout
echo "Select the branch you want to checkout & publish:"
echo "1) main"
echo "2) master"
echo "3) develop"
echo -e "4) Stay on current branch (\033[0;32mCurrent branch: $(git branch --show-current)\033[0m)"
echo "5) Exit"

read -p "Enter your choice [1-5]: " branch_option

case $branch_option in
    1)
        git checkout main && git pull --ff-only || { echo "The selected branch checkout process has failed. Exiting..."; exit 1; }
        ;;
    2)
        git checkout master && git pull --ff-only || { echo "The selected branch checkout process has failed. Exiting..."; exit 1; }
        ;;
    3)
        git checkout develop && git pull --ff-only || { echo "The selected branch checkout process has failed. Exiting..."; exit 1; }
        ;;
    4)
        # Stay on current branch, do nothing
        ;;
    5)
        # Exit
        exit 1
        ;;
    *)
        echo "Invalid selection"
        exit 1
        ;;
esac

if [ $branch_option -ne 5 ]; then
    echo "I pulled down the latest version of the code..."
    git pull

    # Run the tests
    echo "Running tests..."
    npm test

    # Check the exit code of the last command (npm test)
    if [ $? -ne 0 ]; then
        # Set text color to red
        tput setaf 1
        echo "Error: Tests are failing. Please fix the failing tests before bumping the version."
        tput sgr0  # Reset text color
        exit 1
    fi
fi

# Check if the script is running in a directory named "client"
if [ "$(basename "$PWD")" != "client" ]; then
    # Set text color to red
    tput setaf 1
    echo "Error: You should be in the client directory"
    tput sgr0  # Reset text color
    exit 1
fi

# Check if package.json exists in the current directory
if [ ! -f package.json ]; then
    # Set text color to red
    tput setaf 1
    echo "Error: No package.json found"
    tput sgr0  # Reset text color
    exit 1
fi

# Set text color to cyan
tput setaf 6
NAME=$(get_name)
echo "The project name is: ${NAME}"
tput setaf 6
VERSION=$(get_version)
echo "The current version of this client is: ${VERSION}"

# Reset text color and add an empty line
tput sgr0
echo

# Ignore case in case command
shopt -s nocasematch

while true; do
    echo "Select an option:"
    echo "A) Bump the version by the NPM version - NPM will automatically update the version number in your package.json file"
    echo "B) Bump the version manually - You have to change the version manually in package.json before choosing this option"
    echo "C) Exit - Close the script without any changes"

    read -r option
    case $option in
        a|A)
            echo "NPM version:"
            echo "a) Major - The version number will increase by 1 in the first digit (for example from 2.3.4 to 3.0.0)"
            echo "b) Minor - The version number will increase by 1 in the second digit (for example from 2.3.4 to 2.4.0)"
            echo "c) Patch - The version number will increase by 1 in the third digit (for example from 2.3.4 to 2.3.5)"

            read -r npm_option

            case $npm_option in
                a|A)
                    npm version major --no-git-tag-version
                    ;;
                b|B)
                    npm version minor --no-git-tag-version
                    ;;
                c|C)
                    npm version patch --no-git-tag-version
                    ;;
                *)
                    echo "Invalid selection"
                    continue
                    ;;
            esac

            write_commands
            exit
            ;;

        b|B)
            write_commands
            exit
            ;;

        c|C)
            exit
            ;;

        *)
            echo "Invalid selection"
            ;;
    esac
done
