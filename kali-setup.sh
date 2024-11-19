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
echo "Starting System Update & Setup..."
sudo apt update -y && sudo apt upgrade -y

# Install necessary tools and dependencies
echo "Installing necessary tools..."
sudo apt install -y git perl tree htop gdu python3-pip curl wget docker.io npm jq nmap phantomjs chromium parallel

# Download bookmarks from tl-osint
echo "Downloading bookmarks from tl-osint"
wget -O ~/Desktop/bookmarks.html https://raw.githubusercontent.com/tracelabs/tlosint-live/master/bookmarks.html

# Create symbolic link to /opt
echo "Creating symbolic link to /opt on Desktop"
if [ -d "/opt" ]; then
  ln -sf /opt ~/Desktop/opt
else
  echo "/opt directory does not exist, skipping link creation..."
fi

# Clone and move shortcuts for additional documents
echo "Cloning kali-setup repository"
REPO_DIR="$(pwd)/kali-setup"
if git clone https://github.com/ryanmrestivo/kali-setup.git "$REPO_DIR"; then
  echo "Moving additional documents to Desktop"
  if [ -d "$REPO_DIR/scripts" ]; then
    mv "$REPO_DIR/scripts"/* ~/Desktop/
  else
    echo "No scripts directory found in kali-setup repository"
  fi
  if [ -d "$REPO_DIR/Wallpapers" ]; then
    mv "$REPO_DIR/Wallpapers" ~/Desktop/
  else
    echo "No Wallpapers directory found in kali-setup repository"
  fi
  rm -rf "$REPO_DIR"
else
  echo "Failed to clone kali-setup repository"
fi

# Set permissions
echo "Setting permissions for /opt"
sudo chmod -R 755 /opt

# Install Go
GO_VERSION="1.21.0"
echo "Installing Go version $GO_VERSION"
curl -LO https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
rm go$GO_VERSION.linux-amd64.tar.gz
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Upgrade pip and install Python packages
python3 -m pip install --upgrade pip
pip install pipenv name-that-hash search-that-hash mitmproxy autopwn-suite

# Install Node.js and npm
echo "Installing Node.js and npm..."
sudo apt install -y nodejs
sudo npm install -g npm wappalyzer wscat

# Install Docker CE
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker --now

# Install exploitdb (searchsploit)
echo "Installing searchsploit"
sudo apt install -y exploitdb
searchsploit -u

# Function to clone GitHub repos to /opt
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

# Install tools
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

# Additional Notes for Specific Tools
# Refer to the documentation comments for additional manual steps where necessary.
