#!/usr/bin/env bash

set -euo pipefail

# Function to display help message
show_help() {
    echo "Usage: $0 [-e] [--clean] [--help]"
    echo ""
    echo "Install BAML queries for Helix editor"
    echo ""
    echo "Options:"
    echo "  -e      Create symlinks instead of copying (for editing)"
    echo "  --clean Remove files from target directory"
    echo "  --help  Display this help message"
    echo ""
    echo "Target directory:"
    echo "  \$HELIX_RUNTIME/queries/baml (if HELIX_RUNTIME is set)"
    echo "  ~/.config/helix/runtime/queries/baml (default)"
}

# Parse command line arguments
SYMLINK_MODE=false
CLEAN_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -e)
            SYMLINK_MODE=true
            shift
            ;;
        --clean)
            CLEAN_MODE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
    esac
done

# Determine target directory
if [[ -n "${HELIX_RUNTIME:-}" ]]; then
    TARGET_DIR="$HELIX_RUNTIME/queries/baml"
else
    TARGET_DIR="$HOME/.config/helix/runtime/queries/baml"
fi

# Get source directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/queries"

# Clean mode: remove target directory and exit
if [[ "$CLEAN_MODE" == "true" ]]; then
    if [[ -d "$TARGET_DIR" ]]; then
        echo "Removing $TARGET_DIR..."
        rm -rf "$TARGET_DIR"
        echo "Cleaned successfully."
    else
        echo "Target directory $TARGET_DIR does not exist."
    fi
    exit 0
fi

# Create target directory if it doesn't exist
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Install files
if [[ "$SYMLINK_MODE" == "true" ]]; then
    echo "Creating symlinks from $SOURCE_DIR to $TARGET_DIR..."
    for file in "$SOURCE_DIR"/*; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            target_file="$TARGET_DIR/$filename"
            
            # Remove existing file/symlink if it exists
            if [[ -e "$target_file" || -L "$target_file" ]]; then
                rm -f "$target_file"
            fi
            
            ln -s "$file" "$target_file"
            echo "  Symlinked: $filename"
        fi
    done
    echo "Symlinks created successfully. You can now edit files in $SOURCE_DIR."
else
    echo "Copying files from $SOURCE_DIR to $TARGET_DIR..."
    for file in "$SOURCE_DIR"/*; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            cp "$file" "$TARGET_DIR/"
            echo "  Copied: $filename"
        fi
    done
    echo "Files copied successfully."
fi

echo "Installation complete!"