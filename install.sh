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
echo -e "${BOLD}Yoru Dotfiles Installer — Elegant Arch Linux Setup${NC}"
echo -e "Author: ${CYAN}pavelc4${NC} | Stack: ${CYAN}Hyprland & Quickshell${NC}"
echo "--------------------------------------------------------"

# 1. Verify OS
if [ ! -f /etc/arch-release ]; then
    warn "This script is optimized for Arch Linux. Proceed with caution."
fi

# 2. Define source paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_SRC="$REPO_DIR/hypr"
QS_SRC="$REPO_DIR/quickshell/yoru"

# 3. Check Dependencies
info "Checking dependencies..."

REQUIRED_BINARIES=(
    "hyprland"
    "quickshell"
    "grim"
    "slurp"
    "wl-copy"
    "hyprpicker"
    "tesseract"
    "curl"
    "jq"
    "wf-recorder"
)

MISSING_BINS=()
for bin in "${REQUIRED_BINARIES[@]}"; do
    if ! command -v "$bin" &> /dev/null; then
        MISSING_BINS+=("$bin")
    fi
done

# Special check for libcava (AUR)
HAS_LIBCAVA=true
if ! pkg-config --exists libcava &> /dev/null && ! pkg-config --exists cava &> /dev/null; then
    HAS_LIBCAVA=false
fi

if [ ${#MISSING_BINS[@]} -ne 0 ] || [ "$HAS_LIBCAVA" = false ]; then
    warn "Some required dependencies or libraries are missing."
    if [ ${#MISSING_BINS[@]} -ne 0 ]; then
        echo -e "  Missing binaries: ${RED}${MISSING_BINS[*]}${NC}"
    fi
    if [ "$HAS_LIBCAVA" = false ]; then
        echo -e "  Missing library: ${RED}libcava${NC} (Required for audio visualizer)"
    fi
    
    echo ""
    read -rp "Would you like to install missing dependencies using yay? [Y/n] " install_deps
    if [[ "$install_deps" =~ ^[YyDd]$ ]] || [ -z "$install_deps" ]; then
        info "Installing dependencies..."
        INSTALL_LIST=()
        for bin in "${MISSING_BINS[@]}"; do
            case "$bin" in
                "hyprland") INSTALL_LIST+=("hyprland") ;;
                "quickshell") INSTALL_LIST+=("quickshell-git") ;;
                "grim") INSTALL_LIST+=("grim") ;;
                "slurp") INSTALL_LIST+=("slurp") ;;
                "wl-copy") INSTALL_LIST+=("wl-clipboard") ;;
                "hyprpicker") INSTALL_LIST+=("hyprpicker") ;;
                "tesseract") INSTALL_LIST+=("tesseract" "tesseract-data-eng") ;;
                "curl") INSTALL_LIST+=("curl") ;;
                "jq") INSTALL_LIST+=("jq") ;;
                "wf-recorder") INSTALL_LIST+=("wf-recorder") ;;
            esac
        done
        
        if [ "$HAS_LIBCAVA" = false ]; then
            INSTALL_LIST+=("libcava")
        fi
        
        if command -v yay &> /dev/null; then
            yay -S --needed "${INSTALL_LIST[@]}"
        elif command -v paru &> /dev/null; then
            paru -S --needed "${INSTALL_LIST[@]}"
        else
            error "No AUR helper (yay/paru) found. Please install: ${INSTALL_LIST[*]} manually."
        fi
    else
        warn "Proceeding without installing missing packages. Builds might fail."
    fi
else
    success "All core dependencies and libraries are present!"
fi

# 4. Build QML C++ Plugin
info "Building and compiling Quickshell QML plugin..."
if [ -d "$QS_SRC" ]; then
    cd "$QS_SRC"
    mkdir -p build
    cd build
    info "Configuring CMake..."
    cmake -DCMAKE_INSTALL_PREFIX=../imports -DINSTALL_QMLDIR=. -DVERSION=0.1.0 -DGIT_REVISION=dev ..
    info "Compiling plugin..."
    make -j$(nproc)
    info "Installing plugin locally..."
    make install
    success "C++ QML Plugin compiled and installed locally to imports/ successfully!"
else
    error "Quickshell configuration path not found in repository: $QS_SRC"
fi

# 5. Backup & Symlink Configurations
info "Setting up symlinks in ~/.config..."
mkdir -p "$HOME/.config"

# Helper for backup and symlink
link_config() {
    local src="$1"
    local dest="$2"
    local name="$3"
    
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        # Check if already symlinked to the correct path
        if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
            success "$name is already correctly symlinked."
            return
        fi
        
        local backup="${dest}.bak.$(date +%Y%m%d_%H%M%S)"
        warn "Existing $name config found! Moving to $backup"
        mv "$dest" "$backup"
    fi
    
    # Create parent folder if missing
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    success "Symlinked $name to $dest"
}

# Link Hyprland Lua Config
link_config "$HYPR_SRC" "$HOME/.config/hypr" "Hyprland Lua"

# Link Quickshell Yoru Config
link_config "$QS_SRC" "$HOME/.config/quickshell/yoru" "Quickshell Yoru"

# Link Terminal Configs (Kitty & Foot)
if [ -d "$REPO_DIR/kitty" ]; then
    link_config "$REPO_DIR/kitty" "$HOME/.config/kitty" "Kitty Terminal"
fi
if [ -d "$REPO_DIR/foot" ]; then
    link_config "$REPO_DIR/foot" "$HOME/.config/foot" "Foot Terminal"
fi

echo "--------------------------------------------------------"
success "Yoru Dotfiles installation completed successfully!"
info "You can now test running quickshell using (works in any shell):"
echo -e "  ${BOLD}env QML2_IMPORT_PATH=~/.config/quickshell/yoru/imports quickshell -p ~/.config/quickshell/yoru/shell.qml${NC}"
info "Or refresh Hyprland to load globally: ${BOLD}hyprctl reload${NC}"

echo "--------------------------------------------------------"
