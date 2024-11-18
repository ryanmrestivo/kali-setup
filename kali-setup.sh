#!/bin/bash

# Kali Setup Script
# Ensure this script has executable permissions: chmod +x kali-setup.sh

# Setting up Global Theme Instructions (Optional Step)
# - Go to Global Theme -> Get New Global Themes -> Sort by Rating -> Sweet KDE

# Prevent Linux from going to sleep (Optional Step)
# - Power Manager -> Display -> Slide everything left to "never"

# System Update and Setup
echo "Starting System Update & Setup..."

# Setting debconf to non-interactive mode to avoid prompts during installation
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

# Update package list and upgrade installed packages
sudo apt update -y && sudo apt upgrade -y

# Install necessary tools and dependencies
sudo apt install -y git perl tree htop gdu python3-pip curl wget docker.io npm

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
sudo apt install -y nodejs
sudo npm install -g npm

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
  echo "Cloning $REPO_URL to $DEST_DIR"
  sudo git clone "$REPO_URL" "$DEST_DIR"
}

# Install tools
TOOLS=(
  "https://github.com/Tib3rius/AutoRecon beta"
  "https://github.com/21y4d/nmapAutomator"
  "https://github.com/Tuhinshubhra/RED_HAWK"
  "https://github.com/D4Vinci/One-Lin3r"
  "https://github.com/knassar702/scant3r"
  "https://github.com/m4ll0k/takeover"
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
  "https://github.com/ryanmrestivo/gmailc2"
  "https://github.com/r00t-3xp10it/resource_files"
)

for TOOL in "${TOOLS[@]}"; do
  git_clone_to_opt $TOOL
done

# Additional steps for specific tools
cd /opt/autorecon
sudo git checkout beta
sudo python3 -m pip install -r requirements.txt

cd /opt/nmapAutomator
sudo ln -s nmapAutomator.sh /usr/local/bin/nmapAutomator

cd /opt/3lckon
chmod +x install_tools.sh
./install_tools.sh
sudo apt install -y jq nmap phantomjs npm chromium parallel
pip3 install npm
npm i -g wappalyzer wscat

# Docker setup
echo "Setting up Docker containers..."
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

# Download bookmarks from tl-osint
echo "Downloading bookmarks from tl-osint"
wget -O ~/Desktop/bookmarks.html https://raw.githubusercontent.com/tracelabs/tlosint-live/master/bookmarks.html

# Create symbolic links
echo "Creating symbolic links"
ln -s /opt/ ~/Desktop/opt
ln -s /opt/_not_installed ~/Desktop/opt/_not_installed

# Set permissions
echo "Setting permissions for /opt"
sudo chmod -R 755 /opt

# Docker service setup
sudo systemctl enable docker --now

# Cleanup
echo "Cleaning up and running final update checks"
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

# Removing unnecessary directories
echo "Removing unnecessary directories"
sudo rm -rf /opt/google /opt/requests

# Reboot prompt
echo "Setup complete. The system will reboot in 60 seconds."
sleep 60
sudo reboot

#
# Additional Notes for Specific Tools
#
# CHAOS
# Run:
# PORT=8080 DATABASE_NAME=chaos go run cmd/chaos/main.go
# /opt/CHAOS/client/main.go
# After running, go to http://localhost:8080 and login with the default username: ***admin*** and password: ***changeme***.

# venom
# Manual steps might be needed here. Check the comments in the original script.

# rengine
# Edit the .env file, please make sure to change the password for PostgreSQL POSTGRES_PASSWORD!
# sudo ./install.sh
# reNgine can be accessed from https://127.0.0.1

# Havoc
# Build the client Binary (From Havoc Root Directory):
# make client-build
# Run the client:
# ./havoc client

# Koadic
# Run:
# ./koadic

# mosquito (resource_files)
# Find and make scripts executable:
# cd mosquito && find ./ -name "*.sh" -exec chmod +x {} \;
