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

if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed"
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
    echo "Downloading $component rules..."
    component_dir=".cursor/rules/$component"
    mkdir -p "$component_dir"
    
    repo_url="https://api.github.com/repos/ShalevAri/cursor-automator/contents/cursor-rules/$component"
    files=$(curl -s "$repo_url")
    
    if ! echo "$files" | grep -q "name"; then
        echo "Error: Failed to fetch file list for $component"
        exit 1
    fi
    
    file_names=$(echo "$files" | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g')
    
    for file in $file_names; do
        download_url="https://raw.githubusercontent.com/ShalevAri/cursor-automator/main/cursor-rules/$component/$file"
        echo "  - Downloading $file"
        if ! curl -s "$download_url" -o "$component_dir/$file"; then
            echo "Error downloading $file"
        fi
    done
done

if [[ " ${selected[@]} " =~ "helper" ]]; then
    echo "TIP: Remember to customize the helper rules!"
fi

echo "SUCCESS: Setup completed successfully"
