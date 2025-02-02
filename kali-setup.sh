#!/bin/bash

# Ensure Desktop directory exists for current user
mkdir -p ~/Desktop

# Kali Setup Script
# Ensure this script has executable permissions: chmod +x kali-setup.sh

# Setting debconf to non-interactive mode to avoid prompts during installation
echo "* libraries/restart-without-asking boolean true" | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

# System Update and Setup
echo "[1/16] Starting System Update & Setup..."
sudo apt update -y && sudo apt upgrade -y

# Install necessary tools and dependencies
echo "[2/16] Installing necessary tools..."
sudo apt install -y git perl tree htop gdu python3-pip curl wget docker.io npm jq nmap phantomjs chromium parallel

# Install pipx for managing Python applications
echo "[3/16] Installing pipx..."
python3 -m pip install --user pipx
python3 -m pipx ensurepath
export PATH=$PATH:~/.local/bin

# Install bbot using pipx
echo "[4/16] Installing bbot..."
pipx install bbot

# Install search-that-hash using pipx
echo "[5/16] Installing search-that-hash..."
pipx install search-that-hash

# Install bleachbit
echo "[6/16] Installing bleachbit..."
sudo apt install -y bleachbit

# Download bookmarks from tl-osint
echo "[7/16] Downloading bookmarks from tl-osint"
wget -O ~/Desktop/bookmarks.html https://raw.githubusercontent.com/tracelabs/tlosint-live/master/bookmarks.html

echo "[8/16] Creating symbolic link to /opt on Desktop"
ln -sf /opt ~/Desktop/opt

# Clone and move shortcuts for additional documents
echo "[9/16] Cloning kali-setup repository"
REPO_DIR="$(pwd)/kali-setup"
if git clone --recurse-submodules https://github.com/ryanmrestivo/kali-setup.git "$REPO_DIR"; then
  echo "Successfully cloned kali-setup repository"
  echo "Moving additional documents to Desktop"
  if [ -d "$REPO_DIR/scripts" ]; then
    mv "$REPO_DIR/scripts"/* ~/Desktop/
  else
    echo "No scripts directory found in kali-setup repository"
  fi
  if [ -d "$REPO_DIR/Wallpapers" ]; then
    mv "$REPO_DIR/Wallpapers" ~/Desktop/
  else
    echo "No Wallpapers directory found in kali-setup repository, please check if the repository has been cloned with all submodules."
  fi
else
  echo "Failed to clone kali-setup repository"
fi

# Verify if kali-setup repository exists
echo "Verifying kali-setup repository..."
if [ -d "$REPO_DIR" ]; then
  echo "kali-setup repository is present at $REPO_DIR"
else
  echo "kali-setup repository is missing, please check the cloning process."
fi

# Set permissions
echo "[10/16] Setting permissions for /opt"
sudo chmod -R 755 /opt

# Install Go
GO_VERSION="1.21.0"
echo "[11/16] Installing Go version $GO_VERSION"
curl -LO https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
rm go$GO_VERSION.linux-amd64.tar.gz
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Upgrade pip and install Python packages
echo "[12/16] Upgrading pip and installing Python packages"
python3 -m pip install --upgrade pip
pip install pipenv name-that-hash mitmproxy autopwn-suite

# Install Node.js and npm
echo "[13/16] Installing Node.js and npm..."
sudo apt install -y nodejs
sudo npm install -g npm wappalyzer wscat

# Install Docker CE
echo "[14/16] Installing Docker CE"
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker --now

# Install exploitdb (searchsploit)
echo "[15/16] Installing searchsploit"
sudo apt install -y exploitdb
searchsploit -u

# Install tools
echo "[16/16] Cloning GitHub repositories to /opt"
git_clone_to_opt() {
  local REPO_URL="$1"
  local DEST_DIR="/opt/${2:-$(basename $REPO_URL .git)}"
  if [ ! -d "$DEST_DIR" ]; then
    echo "Cloning $REPO_URL to $DEST_DIR"
    sudo git clone "$REPO_URL" "$DEST_DIR" || { echo "Failed to clone $REPO_URL"; exit 1; }
  else
    echo "$DEST_DIR already exists, skipping..."
  fi
}

TOOLS=(
  "https://github.com/Tib3rius/AutoRecon beta"
  "https://github.com/21y4d/nmapAutomator"
  "https://github.com/Tuhinshubhra/RED_HAWK"
  "https://github.com/D4Vinci/One-Lin3r"
  "https://github.com/knassar702/scant3r"
  "https://github.com/aristocratos/bashtop"
  "https://github.com/darkoperator/dnsrecon"
  "https://github.com/elceef/dnstwist"
  "https://github.com/peterpt/eternal_scanner"
  "https://github.com/Cyb0r9/ispy"
  "https://github.com/skavngr/rapidscan"
  "https://github.com/trimstray/sandmap"
  "https://github.com/smicallef/spiderfoot"
  "https://github.com/j3ssie/Osmedeus"
  "https://github.com/alexandreborges/malwoverview"
  "https://github.com/projectdiscovery/nuclei"
  "https://github.com/VainlyStrain/Vailyn"
  "https://github.com/eslam3kl/3klCon"
  "https://github.com/t3l3machus/hoaxshell"
  "https://github.com/iamthefrogy/frogy"
  "https://github.com/R0X4R/Garud"
  "https://github.com/HavocFramework/Havoc"
  "https://github.com/ryanmrestivo/koadic"
  "https://github.com/Veil-Framework/Veil"
  "https://github.com/leebaird/discover"
  "https://github.com/six2dez/reconftw"
  "https://github.com/robotshell/magicRecon"
  "https://github.com/chvancooten/BugBountyScanner"
  "https://github.com/r00t-3xp10it/venom"
  "https://github.com/yogeshojha/rengine"
  "https://github.com/sahullander/Purple-Pwny"
  "https://github.com/byt3bl33d3r/SILENTTRINITY"
  "https://github.com/scipag/vulscan"
  "https://github.com/0xinfection/tidos-framework"
  "https://github.com/mazen160/shennina"
  "https://github.com/morpheuslord/GPT_Vuln-analyzer"
  "https://github.com/Screetsec/TheFatRat"
  "https://github.com/shmilylty/OneForAll"
  "https://github.com/D4Vinci/Cr3dOv3r"
  "https://github.com/BC-SECURITY/Empire"
  "https://github.com/screetsec/Sudomy"
  "https://github.com/hlldz/SpookFlare"
  "https://github.com/trustedsec/unicorn"
  "https://github.com/D4Vinci/Cuteit"
  "https://github.com/TryCatchHCF/Cloakify"
  "https://github.com/tiagorlampert/CHAOS"
  "https://github.com/aboul3la/Sublist3r"
  "https://github.com/g0tmi1k/msfpc"
  "https://github.com/tess-ss/recon-ninja"
  "https://github.com/r00t-3xp10it/resource_files"
)

for TOOL in "${TOOLS[@]}"; do
  git_clone_to_opt $TOOL &
done
wait

# install nuclei
echo installing nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

echo installing osmedeus
# install osmedeus
go install -v github.com/j3ssie/osmedeus@latest

# Docker setup
echo "Setting up Docker containers..."
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

# Cleanup
echo "Cleaning up and running final update checks"
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

# Removing unnecessary directories
echo "Removing unnecessary directories"
sudo rm -rf /opt/google /opt/requests

# Remove the script from Desktop after execution
echo "Deleting the script from Desktop"
rm -- "$0"

# Additional Notes for Specific Tools
# Refer to the documentation comments for additional manual steps where necessary.

# Making scripts on Desktop executable
chmod +x ~/Desktop/*

# python3 -m venv oneforall_env
# source oneforall_env/bin/activate