#!/bin/bash

# Source the script with the functions
source link_scripts_to_config.sh

# Function to update .zshrc
update_zshrc() {
    local script_path=$(realpath "link_scripts_to_config.sh")

    # Check if .zshrc already contains the call
    if grep -q "$script_path" "$HOME/.zshrc"; then
        echo ".zshrc already updated."
    else
        # Add the call to .zshrc
        echo "# Automatically link scripts" >> "$HOME/.zshrc"
        echo "source $script_path" >> "$HOME/.zshrc"
        echo ".zshrc updated successfully."
    fi
}

# Main script logic
case "$1" in
    install)
        install_scripts
        update_zshrc
        ;;
    cleanup)
        cleanup_scripts
        ;;
    *)
        echo "Usage: $0 {install|cleanup}"
        exit 1
        ;;
esac
