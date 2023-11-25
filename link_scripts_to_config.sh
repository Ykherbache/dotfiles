#!/bin/bash
 
# Function to link files recursively
link_files_recursively() {
    local source_dir=$1
    local target_dir=$2
    local depth=$3

    if [ $depth -le 0 ]; then
        return
    fi

    for item in "$source_dir"/*; do
        if [ -f "$item" ]; then
            local item_name=$(basename "$item")
            ln -sf "$item" "$target_dir/$item_name"
        elif [ -d "$item" ]; then
            link_files_recursively "$item" "$target_dir" $((depth-1))
        fi
    done
}

# Function to cleanup files recursively
cleanup_files_recursively() {
    local source_dir=$1
    local target_dir=$2

    for item in "$source_dir"/*; do
        local item_name=$(basename "$item")

        if [ -f "$item" ]; then
            # If a symbolic link exists in the target directory, remove it
            if [ -L "$target_dir/$item_name" ]; then
                rm "$target_dir/$item_name"
            fi
        elif [ -d "$item" ]; then
            # If it's a directory, recurse into it
            cleanup_files_recursively "$item" "$target_dir"
        fi
    done
}

# Function to install scripts
install_scripts() {
    local script_dir=$(dirname $(realpath "$0"))/scripts
    local config_dir=$HOME/.config
    local depth=2

    link_files_recursively "$script_dir" "$config_dir" $depth
    echo "Scripts installed successfully."
}

# Function to clean up scripts
cleanup_scripts() {
    local script_dir=$(dirname $(realpath "$0"))/scripts
    local config_dir=$HOME/.config

    cleanup_files_recursively "$script_dir" "$config_dir"
    echo "Scripts cleanup completed."
}
