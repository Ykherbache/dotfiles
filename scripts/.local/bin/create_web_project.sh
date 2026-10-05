#!/bin/bash

# Get the full path of the script, resolving symlinks
script_path=$(realpath "$0")

# Extract the directory path from the full script path
script_dir=$(dirname "$script_path")

# Source utility scripts using the determined script directory
source "$script_dir/core/create_folder.sh"
source "$script_dir/core/create_main_js.sh"
source "$script_dir/core/create_main_css.sh"
source "$script_dir/core/create_index_html.sh"
source "$script_dir/core/display_usage.sh"

main() {
    # Prompt the user for the folder name
    echo -n "Enter the name of the folder for the web project: "
    read FOLDER_NAME

    # Check if the folder name is empty
    if [ -z "$FOLDER_NAME" ]; then
        echo "No folder name entered. Exiting."
        exit 1
    fi

    create_folder "$FOLDER_NAME"
    create_main_js
    create_main_css
    create_index_html "$FOLDER_NAME"

    echo "Web project '$FOLDER_NAME' has been created successfully."
    code .
}

main
