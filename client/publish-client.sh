#!/bin/bash

# Clear the screen
clear

# Function to get version from package.json
get_version() {
    grep '"version"' package.json | cut -d '"' -f4
}

get_name() {
    grep '"name"' package.json | cut -d '"' -f4
}

write_commands() {
    local NEW_VERSION=$(get_version)

    echo "You should run these commands now in the same order:"
    echo
    echo "------------------------------------------------------------------------------------"
    echo

    echo "git tag client-${NEW_VERSION}"
    echo "git add ."
    echo "git commit -m\"Client's version has been bumped to: ${NEW_VERSION}\""
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

# Checkout to the main branch and pull the latest changes
echo "I check out the main branch..."
git checkout main

echo "I pulled down the latest version of the code..."
git pull

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
    echo "A) Bump the version by the NPM version"
    echo -e "B) Bump the version manually $(tput setaf 6)(BEFORE press B -> you have to change the version manually in package.json)$(tput sgr0)"
    echo "C) Exit"

    read -r option
    case $option in
        a|A)
            echo "NPM version:"
            echo "a) Major"
            echo "b) Minor"
            echo "c) Patch"

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
