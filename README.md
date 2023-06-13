# Version Bump and Publish Script

This script is an assistant tool for maintaining JavaScript and TypeScript packages (not services), specifically those managed with NPM and Git. It provides automated assistance with versioning and preparing the project for publication.

## Usage

To use this script, you should copy it to your project's root directory. Then, you can run it directly from your terminal with the command `./publish-client.sh`. The script will guide you through its process via a series of prompts and messages.

**Important**: The script does not execute any command. It just generates commands you can run if you want to publish your script.


## Features

- **Automated Version Bumping**: The script facilitates version incrementation according to semantic versioning. It provides two ways to bump the version:
    - By using the `npm version` command. You can choose to increment the major, minor, or patch version.
    - Manually, by allowing you to edit the `package.json` file yourself.

- **Git Commands Generation**: The script generates a list of git commands for you to run in order to tag the new version and push your changes to the repository. It doesn't execute these commands, giving you full control and allowing for manual review.

- **Uncommitted Changes Check**: It checks if there are uncommitted changes in your current branch. If it finds any, it informs you and halts its process until these changes are committed. This way, it helps maintain a clean state in your version control system.

- **Automated Switch to Main Branch**: The script automatically switches to the `main` branch and pulls the latest changes before proceeding with its operations. This ensures you're always working with the latest codebase.

- **Project Directory Check**: The script verifies it's being run within the correct project directory. It looks for the presence of a `package.json` file and a specific directory name (`client`) before proceeding.

