#!/usr/bin/env bash

# Setup strict error handling
set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print helper functions
info() { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"; }
error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; exit 1; }

echo -e "${MAGENTA}${BOLD}"
echo "██╗   ██╗ ██████╗ ██████╗ ██╗   ██╗"
echo "╚██╗ ██╔╝██╔═══██╗██╔══██╗██║   ██║"
echo " ╚████╔╝ ██║   ██║██████╔╝██║   ██║"
echo "  ╚██╔╝  ██║   ██║██╔══██╗██║   ██║"
echo "   ██║   ╚██████╔╝██║  ██║╚██████╔╝"
echo "   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ "
echo -e "${NC}"
echo -e "${BOLD}Yoru Dotfiles Uninstaller — Safe Configuration Reverter${NC}"
echo -e "Author: ${CYAN}pavelc4${NC} | Stack: ${CYAN}Hyprland & Quickshell${NC}"
echo "--------------------------------------------------------"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Helper function to find the latest backup folder
find_latest_backup() {
    local target="$1"
    # List backups matching target.bak.* sorted by modified time (newest first)
    local backups=($(ls -td "${target}.bak."* 2>/dev/null || true))
    if [ ${#backups[@]} -gt 0 ]; then
        echo "${backups[0]}"
    else
        echo ""
    fi
}

# Helper to remove a symlink and offer backup restoration
unlink_and_restore() {
    local dest="$2"
    local name="$1"
    
    # Check if target exists and is a symlink
    if [ -L "$dest" ]; then
        # Verify it points to our repo to avoid breaking unrelated setups
        local target_path
        target_path="$(readlink -f "$dest" || true)"
        if [[ "$target_path" == "$REPO_DIR"* ]]; then
            info "Removing $name symlink: $dest"
            rm "$dest"
            success "Removed $name symlink successfully."
            
            # Look for backups
            local latest_backup
            latest_backup=$(find_latest_backup "$dest")
            if [ -n "$latest_backup" ] && [ -d "$latest_backup" ]; then
                echo -e "${CYAN}➜ Found backup:${NC} $(basename "$latest_backup")"
                read -rp "Would you like to restore this backup? [Y/n] " restore_choice
                if [[ "$restore_choice" =~ ^[YyDd]$ ]] || [ -z "$restore_choice" ]; then
                    mv "$latest_backup" "$dest"
                    success "Restored backup to $dest successfully!"
                else
                    info "Skipped backup restoration for $name."
                fi
            fi
        else
            warn "$dest is a symlink but does not point to the Yoru repo. Skipping."
        fi
    elif [ -e "$dest" ]; then
        warn "$dest exists but is a physical file/folder, not a symlink. Skipping to prevent data loss."
    else
        info "$name config ($dest) is not currently symlinked. Skipping."
    fi
    echo ""
}

# 1. Unlink Configurations and Restore Backups
info "Reverting ~/.config symlinks..."
echo ""

unlink_and_restore "Hyprland Lua" "$CONFIG_DIR/hypr"
unlink_and_restore "Quickshell Yoru" "$CONFIG_DIR/quickshell/yoru"
unlink_and_restore "Kitty Terminal" "$CONFIG_DIR/kitty"
unlink_and_restore "Foot Terminal" "$CONFIG_DIR/foot"

# 2. Prompt for clean build removal
info "Checking compiled build files..."
BUILD_DIR="$REPO_DIR/quickshell/yoru/build"
IMPORTS_DIR="$REPO_DIR/quickshell/yoru/imports"

if [ -d "$BUILD_DIR" ] || [ -d "$IMPORTS_DIR" ]; then
    read -rp "Would you like to completely delete the local C++ build and imports cache folders? [y/N] " clean_choice
    if [[ "$clean_choice" =~ ^[Yy]$ ]]; then
        info "Cleaning build files..."
        rm -rf "$BUILD_DIR" "$IMPORTS_DIR"
        success "Local build and imports directories deleted cleanly."
    else
        info "Retained build caches."
    fi
fi

echo "--------------------------------------------------------"
success "Yoru Dotfiles configurations reverted cleanly!"
info "Thank you for using Yoru!"
echo "--------------------------------------------------------"
