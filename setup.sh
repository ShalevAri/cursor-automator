#!/bin/bash

set -e

get_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn || { echo "Error reading input"; exit 1; }
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n";;
        esac
    done
}

if ! command -v git &> /dev/null; then
    echo "Error: git is not installed"
    exit 1
fi

selected=()

if get_yes_no "Would you like to use General Rules?"; then
    selected+=("general")
    selected+=("rules-new")
fi

if get_yes_no "Would you like to add Helper Rules?"; then
    selected+=("helper") 
fi

if get_yes_no "Would you like to add New Project Rules?"; then
    selected+=("new-projects")
fi

# NOTE: Temporarily disabled
# if get_yes_no "Would you like to add Personas?"; then
#     selected+=("personas")
# fi

if get_yes_no "Would you like to add Security Rules?"; then
    selected+=("security")
fi

if get_yes_no "Would you like to add Tool Rules?"; then
    selected+=("tools")
fi

if [ ${#selected[@]} -eq 0 ]; then
    echo "Error: No components selected"
    exit 1
fi


mkdir -p ".cursor/rules" || { echo "Error creating directories"; exit 1; }

for component in "${selected[@]}"; do
    echo "Cloning $component..."
    if ! git clone "https://github.com/ShalevAri/cursor-automator/tree/main/cursor-rules/$component" ".cursor/rules/$component" 2>/dev/null; then
        echo "Error cloning $component"
        exit 1
    fi
done

if [[ " ${selected[@]} " =~ "helper" ]]; then
    echo "TIP: Remember to customize the helper rules!"
fi

echo "SUCCESS: Setup completed successfully"
