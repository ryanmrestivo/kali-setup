#!/bin/bash

# ==============================================================================
# Kali Update Script - Refactored
# ==============================================================================
# Description: Updates system packages, global NPM packages, Go binaries,
#              and all tool repositories in /opt.
# ==============================================================================

LOG_FILE="kali-update.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; exit 1; }

# --- Functions ---

update_system() {
    log "Updating system packages (APT)..."
    sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y
    info "System packages updated."
}

update_npm() {
    log "Updating global NPM packages..."
    if command -v npm &>/dev/null; then
        sudo npm install -g npm@latest
        sudo npm update -g
        info "NPM packages updated."
    else
        warn "NPM not found, skipping."
    fi
}

update_python_tools() {
    log "Updating pipx packages..."
    if command -v pipx &>/dev/null; then
        local RUN_AS="sudo -u ${SUDO_USER:-$USER}"
        $RUN_AS pipx upgrade-all
        info "Pipx packages updated."
    else
        warn "pipx not found, skipping."
    fi
}

update_go_bins() {
    log "Updating Go-installed binaries..."
    if command -v nuclei &>/dev/null; then
        nuclei -ut
    fi
    # Re-run install for latest versions
    if [[ -f "/usr/local/go/bin/go" ]]; then
        /usr/local/go/bin/go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
        /usr/local/go/bin/go install -v github.com/j3ssie/osmedeus@latest
        info "Go binaries updated."
    fi
}

update_opt_tools() {
    log "Updating tools in /opt..."
    if [ -d "/opt" ]; then
        for dir in /opt/*; do
            if [ -d "$dir/.git" ]; then
                log "Updating $dir..."
                cd "$dir" && sudo git pull --rebase
            fi
        done
        info "All git repositories in /opt updated."
    else
        warn "/opt directory not found, skipping."
    fi
}

update_bookmarks() {
    log "Updating OSINT bookmarks..."
    USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
    DESKTOP_DIR="$USER_HOME/Desktop"
    if [ -d "$DESKTOP_DIR" ]; then
        wget -qO "$DESKTOP_DIR/bookmarks.html" https://raw.githubusercontent.com/tracelabs/tlosint-live/master/bookmarks.html
        info "Bookmarks updated."
    fi
}

# --- Main Execution ---

main() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root."
    fi

    update_system
    update_npm
    update_python_tools
    update_go_bins
    update_opt_tools
    update_bookmarks

    info "Update complete!"
}

main "$@"
