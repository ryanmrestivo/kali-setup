#!/bin/bash

# Kali Setup

# Setting up Global Theme
# Go to Global Theme -> Get New Global Themes -> Sort by Rating -> Sweet KDE

# Make sure file has needed permissions
# chmod +x Kali_Setup.sh

# Prepare file for execution
# dos2unix file.sh

# Prevent Linux from going to sleep
# Power Manager -> Display -> Slide everything left to "never"

echo "System Update & Setup"

# Setting debconf to non-interactive mode to avoid prompts during installation
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

# Update package list and upgrade installed packages
sudo apt -q -y update
yes | sudo apt -q upgrade

# Install git and perl
sudo apt-get -q -y install git perl

# Install Go
echo "Installing Go"
curl -O https://golang.org/dl/go1.16.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz
rm go1.16.linux-amd64.tar.gz
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin

# Installing npm
sudo apt install Node.js 

echo "Installing Basic/Other Tools"

# Install Basic/Other Tools
sudo apt-get -q -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin tree htop gdu nodejs

# Install Python packages and tools
pip install --upgrade pip
pip install pipenv
pip3 install name-that-hash search-that-hash
python2 -m pip install pipenv
python3 -m pip install pipenv mitmproxy

echo "Installing searchsploit"
sudo apt -q update && sudo apt -q -y install exploitdb
echo "Upgrading searchsploit"
searchsploit -u

echo "Installing Beta AutoRecon"
sudo git clone --branch beta https://github.com/Tib3rius/AutoRecon /opt/autorecon
cd /opt/autorecon
sudo git pull
sudo git checkout beta
sudo python3 -m pip install -r requirements.txt

echo "Installing nmapAutomator"
sudo git clone https://github.com/21y4d/nmapAutomator.git /opt/nmapautomator/
sudo ln -s /opt/nmapautomator/nmapAutomator.sh /usr/local/bin/

echo "Downloading RED_HAWK"
sudo git clone https://github.com/Tuhinshubhra/RED_HAWK.git /opt/redhawk

echo "Downloading One-Lin3r"
sudo git clone https://github.com/D4Vinci/One-Lin3r.git /opt/one-liner
pip install one-lin3r

echo "Downloading scant3r"
sudo git clone https://github.com/knassar702/scant3r /opt/scanter
cd /opt/scanter
pip3 install -r requirements.txt

echo "Installing takeover"
sudo git clone https://github.com/m4ll0k/takeover.git /opt/takeover
cd /opt/takeover
python3 setup.py install

echo "Installing bashtop"
sudo git clone https://github.com/aristocratos/bashtop.git /opt/bashtop
cd /opt/bashtop/DEB
./build

echo "Installing dnsrecon"
sudo git clone https://github.com/darkoperator/dnsrecon.git /opt/dnsrecon
cd /opt/dnsrecon/
pip3 install -r requirements.txt

echo "Installing dnstwist"
sudo git clone https://github.com/elceef/dnstwist.git /opt/dnstwist
sudo apt -q -y install python3-dnspython python3-geoip python3-whois python3-requests python3-ssdeep
cd /opt/dnstwist/
pip3 install -r requirements.txt

echo "Installing AutoPWN-Suite"
pip install autopwn-suite

echo "Installing eternal_scanner"
sudo git clone https://github.com/peterpt/eternal_scanner.git /opt/eternalscanner
cd /opt/eternalscanner
sudo apt -q install masscan wget python-pip python-crypto python-impacket python-pyasn1-modules netcat
pip install crypto impacket pyasn1-modules
chmod +x escan

echo "Installing ispy"
sudo git clone https://github.com/Cyb0r9/ispy.git /opt/ispy
cd /opt/ispy
chmod +x setup.sh ispy

echo "Installing rapidscan"
sudo git clone https://github.com/skavngr/rapidscan.git /opt/rapidscan
cd /opt/rapidscan
chmod +x rapidscan.py

echo "Installing sandmap"
sudo git clone https://github.com/trimstray/sandmap.git /opt/sandmap
cd /opt/sandmap
sudo apt -q -y install xterm
chmod +x setup.sh
./setup.sh install

echo "Installing spiderfoot"
sudo git clone https://github.com/smicallef/spiderfoot.git /opt/spiderfoot
cd /opt/spiderfoot
pip3 install -r requirements.txt

echo "Installing bbot"
pip install bbot

echo "Installing Osmedeus"
sudo git clone https://github.com/j3ssie/Osmedeus.git /opt/osmedeus
cd /opt/osmedeus/
bash -c "$(curl -fsSL https://raw.githubusercontent.com/osmedeus/osmedeus-base/master/install.sh)"
mkdir -p $GOPATH/src/github.com/j3ssie
sudo git clone --depth=1 https://github.com/j3ssie/osmedeus $GOPATH/src/github.com/j3ssie/osmedeus
cd $GOPATH/src/github.com/j3ssie/osmedeus
make build

echo "Installing malwoverview"
sudo git clone https://github.com/alexandreborges/malwoverview.git /opt/malwoverview
cd /opt/malwoverview
pip install -r requirements.txt

echo "Installing nuclei"
sudo git clone https://github.com/projectdiscovery/nuclei.git /opt/nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

echo "Installing Vailyn"
sudo git clone https://github.com/VainlyStrain/Vailyn /opt/Vailyn
cd /opt/Vailyn
pip install -r requirements.txt

echo "Installing 3klCon"
sudo git clone https://github.com/eslam3kl/3klCon.git /opt/3lckon/
cd /opt/3lckon/
chmod +x install_tools.sh
./install_tools.sh
sudo apt-get -q install jq nmap phantomjs npm chromium parallel
pip3 install npm
npm i -g wappalyzer wscat

echo "Installing Nodesub"
npm install -g nodesub

echo "installing Trufflehog"
cd /opt/Trufflehog
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

echo "Installing hoaxshell"
sudo git clone https://github.com/t3l3machus/hoaxshell /opt/hoaxshell
cd /opt/hoaxshell
pip3 install -r requirements.txt
chmod +x hoaxshell.py

echo "Installing frogy"
sudo git clone https://github.com/iamthefrogy/frogy.git /opt/frogy
cd /opt/frogy/
chmod +x install.sh
./install.sh

echo "Installing Garud"
sudo git clone https://github.com/R0X4R/Garud.git /opt/Garud
cd /opt/Garud/
chmod +x garud install.sh
sudo mv garud /usr/bin/
./install.sh

echo "Installing Havoc"
git clone https://github.com/HavocFramework/Havoc.git /opt/HavocFramework/Havoc
sudo apt install -y git build-essential apt-utils cmake libfontconfig1 libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev qtdeclarative5-dev golang-go qtbase5-dev libqt5websockets5-dev python3-dev libboost-all-dev mingw-w64 nasm
# Build the client Binary (From Havoc Root Directory)
# make client-build
# Run the client
# ./havoc client

echo "Installing Koadic"
git clone https://github.com/ryanmrestivo/koadic.git /opt/koadic
cd koadic
pip3 install -r requirements.txt
# ./koadic

echo "Installing Sliver"
cd /home/kali/Desktop/kali-setup/
sudo bash install
rm -rf install

echo "Downloads to /opt/_not_installed/"
echo "Downloads to /opt/_not_installed/"
echo "Downloads to /opt/_not_installed/"
# Manual steps might be needed here. Check the comments in the original scripts.

echo "Downloading venom"
sudo git clone https://github.com/r00t-3xp10it/venom.git /opt/_not_installed/venom
# Manual steps might be needed here. Check the comments in the original script.

echo "Downloading ReNgine"
git clone https://github.com/yogeshojha/rengine /opt/_not_installed
# nano .env
# Edit the dotenv file, please make sure to change the password for postgresql POSTGRES_PASSWORD!
# sudo ./install.sh
# reNgine can be accessed from https://127.0.0.1 

echo "Downloading Purple-Pwny"
sudo git clone https://github.com/sahullander/Purple-Pwny.git /opt/_not_installed/Purple-Pwny

echo "Downloading SILENTTRINITY"
sudo git clone https://github.com/byt3bl33d3r/SILENTTRINITY.git /opt/_not_installed/silenttrinity

echo "Downloading vulscan"
sudo git clone https://github.com/scipag/vulscan.git /opt/_not_installed/vulscan

echo "Downloading tidos-framework"
sudo git clone https://github.com/0xinfection/tidos-framework.git /opt/_not_installed/tidos-framework

echo "Downloading shennina"
sudo git clone https://github.com/mazen160/shennina.git /opt/_not_installed/shennina
pip3 install tensorflow

echo "Downloading GPT_Vuln-analyzer"
sudo git clone https://github.com/morpheuslord/GPT_Vuln-analyzer.git /opt/_not_installed/GPT_Vuln-analyzer

echo "Downloading TheFatRat"
sudo git clone https://github.com/Screetsec/TheFatRat.git /opt/_not_installed/thefatrat

echo "Downloading OneForAll"
sudo git clone https://github.com/shmilylty/OneForAll.git /opt/_not_installed/oneforall

echo "Downloading Cr3dOv3r"
sudo git clone https://github.com/D4Vinci/Cr3dOv3r.git /opt/_not_installed/cr3dOv3r

echo "Downloading Empire"
sudo git clone https://github.com/BC-SECURITY/Empire.git /opt/_not_installed/empire

echo "Downloading Sudomy"
sudo git clone --recursive https://github.com/screetsec/Sudomy.git /opt/_not_installed/Sudomy

echo "Downloading SpookFlare"
sudo git clone https://github.com/hlldz/SpookFlare.git /opt/_not_installed/spookflare

echo "Downloading Unicorn"
sudo git clone https://github.com/trustedsec/unicorn.git /opt/_not_installed/unicorn

echo "Downloading Cuteit"
sudo git clone https://github.com/D4Vinci/Cuteit.git /opt/cuteit

echo "Downloading Cloakify"
sudo git clone https://github.com/TryCatchHCF/Cloakify.git /opt/_not_installed/cloakify

echo "Downloading CHAOS"
sudo git clone https://github.com/tiagorlampert/CHAOS.git /opt/_not_installed/chaos
# Run
# PORT=8080 DATABASE_NAME=chaos go run cmd/chaos/main.go
# /opt/CHAOS/client/main.go
# After running go to http://localhost:8080 and login with the default username: ***admin*** and password: ***changeme***.

echo "Downloading Sublist3r"
sudo git clone https://github.com/aboul3la/Sublist3r.git /opt/_not_installed/sublister

echo "Downloading msfpc"
sudo git clone https://github.com/g0tmi1k/msfpc /opt/_not_installed/msfvenom-payload-creator

echo "Downloading recon-ninja"
git clone https://github.com/tess-ss/recon-ninja.git /opt/_not_installed/recon-ninja

echo "Downloading gmailc2"
git clone  https://github.com/ryanmrestivo/gmailc2.git /opt/_not_installed/gmailc2

echo " Downloading - r00t-3xp10it/resource_files (mosquito) "
# https://github.com/r00t-3xp10it/resource_files
git clone  https://github.com/r00t-3xp10it/resource_files /opt/_not_installed/mosquito
# cd mosquito & find ./ -name "*.sh" -exec chmod +x {} \;

#Interactive installs

echo "Installing Veil-Framework"
sudo git clone https://github.com/Veil-Framework/Veil.git /opt/Veil
cd /opt/Veil/config/
./setup.sh --force --silent
sudo apt -q -y install veil

echo "Installing discover"
sudo git clone https://github.com/leebaird/discover /opt/discover/
cd /opt/discover/
./update.sh

echo "Installing reconftw"
sudo git clone https://github.com/six2dez/reconftw.git /opt/reconftw
cd /opt/reconftw
./install.sh

echo "Installing magicRecon"
sudo git clone https://github.com/robotshell/magicRecon /opt/magicRecon
cd /opt/magicRecon
chmod +x install.sh
./install.sh

sudo git clone https://github.com/chvancooten/BugBountyScanner.git /opt/BugBountyScanner
cd /opt/BugBountyScanner
chmod +x BugBountyScanner.sh setup.sh
./setup.sh -t /custom/tools/dir

echo "Downloading Remot3d"
sudo git clone https://github.com/KeepWannabe/Remot3d.git /opt/remot3d

bleachbit

# vulsvan
# nmap -sV --script=vulscan/vulscan.nse scanme.nmap.org
# vulners
# nmap -sV --script vulners --script-args mincvss=5.0 scanme.nmap.org

# Setup Docker Tools

# docker container ls -a
# docker container management
# docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
#    --restart=always \
#    -v /var/run/docker.sock:/var/run/docker.sock \
#    -v portainer_data:/data \
#    portainer/portainer-ce:latest
# 0.0.0.0:9443 should be the default URL.

# docker pull iknowjason/aria-base:latest
# docker run -ti iknowjason/aria-base:latest
# docker pull shmilylty/oneforall
# docker run -it --rm shmilylty/oneforall
# docker pull offensivedockerfiles/v3n0m-scanner
# docker run -it offensivedockerfiles/v3n0m-scanner
# docker pull offensivedockerfiles/gitminer
# docker run -it offensivedockerfiles/gitminer
# docker pull koutto/jok3r
# docker run -i -t --name jok3r-container -w /root/jok3r -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --shm-size 2g --net=host koutto/jok3r
# docker pull shmilylty/oneforall
# docker run -it --rm shmilylty/oneforall
# docker pull vainlystrain/tidos-framework
# docker run -it vainlystrain/tidos-framework
# docker pull rustscan/rustscan
# docker run -it rustscan/rustscan

# Get bookmarks from tl-osint
echo "Downloading bookmarks from tl-osint"
wget -O /home/kali/Desktop/bookmarks.html https://raw.githubusercontent.com/tracelabs/tlosint-live/master/bookmarks.html

# get nmap-bootstrap-xsl
echo "Downloading nmap-bootstrap-xsl"
git clone https://github.com/ryanmrestivo/nmap-bootstrap-xsl.git /home/kali/Desktop/

# Create symbolic links
echo "Creating symbolic links"
ln -s /opt/ /home/kali/Desktop/opt
ln -s /opt/_not_installed /home/kali/Desktop/opt/_not_installed

# Setup file structures
echo "Setting permissions"
sudo chmod -R 755 /opt

find /home/kali/Desktop/kali-setup/Desktop/ -type f -exec mv {} ~/Desktop \;

find /home/kali/Desktop/kali-setup/Wallpapers/  -type f -exec mv {} ~/Desktop \;

mv /home/kali/Desktop/kali-setup/setup.sh ~/Desktop

chmod + 777 htop.sh
chmod + 777 searchsploit.sh
chmod + 777 tree.sh
chmod + 777 update.sh
chmod + 777 bbot.sh
chmod + 777 bashtop.sh
chmod + 777 autopwn-suite.sh
chmod + 777 name-that-hash.sh

# Docker setup
docker volume create portainer_data
sudo systemctl enable docker --now

# Cleanup
echo "Cleaning up and running final update checks"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Removing unnecessary directories
echo "Removing unnecessary directories"
sudo rm -rf /opt/google
sudo rm -rf /opt/requests

# Reboot prompt
echo "Finished! The system will reboot in 60 seconds!"
echo "Finished! The system will reboot in 60 seconds!"
echo "Finished! The system will reboot in 60 seconds!"
sleep 60
sudo reboot