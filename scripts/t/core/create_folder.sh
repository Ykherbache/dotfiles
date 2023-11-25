#!/bin/bash
create_folder() {
    local FOLDER_NAME=$1
    mkdir -p "$FOLDER_NAME" || { echo "Error creating folder $FOLDER_NAME"; exit 1; }
    cd "$FOLDER_NAME"
}
