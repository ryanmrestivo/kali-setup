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
echo "\n\n\nInstalling Go\n"
curl -O https://golang.org/dl/go1.16.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz
rm go1.16.linux-amd64.tar.gz
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin

echo "\n\n\nInstalling Basic/Other Tools\n"

# Install Basic/Other Tools
sudo apt-get -q -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin tree htop bleachbit gdu nodejs

# Install Python packages and tools
pip install --upgrade pip
pip install pipenv
pip3 install name-that-hash search-that-hash
python2 -m pip install pipenv
python3 -m pip install pipenv mitmproxy

echo "\n\n\nInstalling searchsploit\n"
sudo apt -q update && sudo apt -q -y install exploitdb
echo "\n\n\nUpgrading searchsploit\n"
searchsploit -u

echo "\n\n\nInstalling Beta AutoRecon\n"
sudo git clone --branch beta https://github.com/Tib3rius/AutoRecon /opt/autorecon
cd /opt/autorecon
sudo git pull
sudo git checkout beta
sudo python3 -m pip install -r requirements.txt

echo "\n\n\nInstalling nmapAutomator\n"
sudo git clone https://github.com/21y4d/nmapAutomator.git /opt/nmapautomator/
sudo ln -s /opt/nmapautomator/nmapAutomator.sh /usr/local/bin/

echo "\n\n\nDownloading RED_HAWK\n"
sudo git clone https://github.com/Tuhinshubhra/RED_HAWK.git /opt/redhawk

echo "\n\n\nDownloading One-Lin3r\n"
sudo git clone https://github.com/D4Vinci/One-Lin3r.git /opt/one-liner
pip install one-lin3r

echo "\n\n\nDownloading scant3r\n"
sudo git clone https://github.com/knassar702/scant3r /opt/scanter
cd /opt/scanter
pip3 install -r requirements.txt

echo "\n\n\nInstalling takeover\n"
sudo git clone https://github.com/m4ll0k/takeover.git /opt/takeover
cd /opt/takeover
python3 setup.py install

echo "\n\n\nInstalling bashtop\n"
sudo git clone https://github.com/aristocratos/bashtop.git /opt/bashtop
cd /opt/bashtop/DEB
./build

echo "\n\n\nInstalling dnsrecon\n"
sudo git clone https://github.com/darkoperator/dnsrecon.git /opt/dnsrecon
cd /opt/dnsrecon/
pip3 install -r requirements.txt

echo "\n\n\nInstalling dnstwist\n"
sudo git clone https://github.com/elceef/dnstwist.git /opt/dnstwist
sudo apt -q -y install python3-dnspython python3-geoip python3-whois python3-requests python3-ssdeep
cd /opt/dnstwist/
pip3 install -r requirements.txt

echo "\n\n\nInstalling AutoPWN-Suite\n"
pip install autopwn-suite

echo "\n\n\nInstalling eternal_scanner\n"
sudo git clone https://github.com/peterpt/eternal_scanner.git /opt/eternalscanner
cd /opt/eternalscanner
sudo apt -q install masscan wget python-pip python-crypto python-impacket python-pyasn1-modules netcat
pip install crypto impacket pyasn1-modules
chmod +x escan

echo "\n\n\nInstalling ispy\n"
sudo git clone https://github.com/Cyb0r9/ispy.git /opt/ispy
cd /opt/ispy
chmod +x setup.sh ispy

echo "\n\n\nInstalling rapidscan\n"
sudo git clone https://github.com/skavngr/rapidscan.git /opt/rapidscan
cd /opt/rapidscan
chmod +x rapidscan.py

echo "\n\n\nInstalling sandmap\n"
sudo git clone https://github.com/trimstray/sandmap.git /opt/sandmap
cd /opt/sandmap
sudo apt -q -y install xterm
chmod +x setup.sh
./setup.sh install

echo "\n\n\nInstalling magicRecon\n"
sudo git clone https://github.com/robotshell/magicRecon /opt/magicRecon
cd /opt/magicRecon
chmod +x install.sh
./install.sh

echo "\n\n\nInstalling spiderfoot\n"
sudo git clone https://github.com/smicallef/spiderfoot.git /opt/spiderfoot
cd /opt/spiderfoot
pip3 install -r requirements.txt

echo "\n\n\nInstalling bbot\n"
pip install bbot

echo "\n\n\nInstalling Osmedeus\n"
sudo git clone https://github.com/j3ssie/Osmedeus.git /opt/osmedeus
cd /opt/osmedeus/
bash -c "$(curl -fsSL https://raw.githubusercontent.com/osmedeus/osmedeus-base/master/install.sh)"
mkdir -p $GOPATH/src/github.com/j3ssie
sudo git clone --depth=1 https://github.com/j3ssie/osmedeus $GOPATH/src/github.com/j3ssie/osmedeus
cd $GOPATH/src/github.com/j3ssie/osmedeus
make build

echo "\n\n\nInstalling malwoverview\n"
sudo git clone https://github.com/alexandreborges/malwoverview.git /opt/malwoverview
cd /opt/malwoverview
pip install -r requirements.txt

echo "\n\n\nInstalling nuclei\n"
sudo git clone https://github.com/projectdiscovery/nuclei.git /opt/nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

sudo git clone https://github.com/chvancooten/BugBountyScanner.git /opt/BugBountyScanner
cd /opt/BugBountyScanner
chmod +x BugBountyScanner.sh setup.sh
./setup.sh -t /custom/tools/dir

echo "\n\n\nInstalling Vailyn\n"
sudo git clone https://github.com/VainlyStrain/Vailyn /opt/Vailyn
cd /opt/Vailyn
pip install -r requirements.txt

echo "\n\n\nInstalling 3klCon\n"
sudo git clone https://github.com/eslam3kl/3klCon.git /opt/3lckon/
cd /opt/3lckon/
chmod +x install_tools.sh
./install_tools.sh
sudo apt-get -q install jq nmap phantomjs npm chromium parallel
pip3 install npm
npm i -g wappalyzer wscat

echo "\n\n\nInstalling hoaxshell\n"
sudo git clone https://github.com/t3l3machus/hoaxshell /opt/hoaxshell
cd /opt/hoaxshell
pip3 install -r requirements.txt
chmod +x hoaxshell.py

echo "\n\n\nInstalling frogy\n"
sudo git clone https://github.com/iamthefrogy/frogy.git /opt/frogy
cd /opt/frogy/
chmod +x install.sh
./install.sh

echo "\n\n\nInstalling Garud\n"
sudo git clone https://github.com/R0X4R/Garud.git /opt/Garud
cd /opt/Garud/
chmod +x garud install.sh
sudo mv garud /usr/bin/
./install.sh

echo "\n\n\nInstalling Havoc\n"
git clone https://github.com/HavocFramework/Havoc.git /opt/HavocFramework/Havoc
sudo apt install -y git build-essential apt-utils cmake libfontconfig1 libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev qtdeclarative5-dev golang-go qtbase5-dev libqt5websockets5-dev python3-dev libboost-all-dev mingw-w64 nasm
# Build the client Binary (From Havoc Root Directory)
# make client-build
# Run the client
# ./havoc client

echo "\n\n\nInstalling Koadic\n"
git clone https://github.com/ryanmrestivo/koadic.git /opt/koadic
cd koadic
pip3 install -r requirements.txt
# ./koadic

echo "\n\n\nInstalling Sliver\n"
cd /home/kali/Desktop/kali-setup/
sudo bash install
rm -rf install

echo "\n\n\nDownloads to /opt/_not_installed/\n"
echo "\n\n\nDownloads to /opt/_not_installed/\n"
echo "\n\n\nDownloads to /opt/_not_installed/\n"
# Manual steps might be needed here. Check the comments in the original scripts.

echo "\n\n\nDownloading venom\n"
sudo git clone https://github.com/r00t-3xp10it/venom.git /opt/_not_installed/venom
# Manual steps might be needed here. Check the comments in the original script.

echo "\n\n\nDownloading ReNgine\n"
git clone https://github.com/yogeshojha/rengine /opt/_not_installed
# nano .env
# Edit the dotenv file, please make sure to change the password for postgresql POSTGRES_PASSWORD!
# sudo ./install.sh
# reNgine can be accessed from https://127.0.0.1 

echo "\n\n\nDownloading Purple-Pwny\n"
sudo git clone https://github.com/sahullander/Purple-Pwny.git /opt/_not_installed/Purple-Pwny

echo "\n\n\nDownloading SILENTTRINITY\n"
sudo git clone https://github.com/byt3bl33d3r/SILENTTRINITY.git /opt/_not_installed/silenttrinity

echo "\n\n\nDownloading vulscan\n"
sudo git clone https://github.com/scipag/vulscan.git /opt/_not_installed/vulscan

echo "\n\n\nDownloading tidos-framework\n"
sudo git clone https://github.com/0xinfection/tidos-framework.git /opt/_not_installed/tidos-framework

echo "\n\n\nDownloading shennina\n"
sudo git clone https://github.com/mazen160/shennina.git /opt/_not_installed/shennina
pip3 install tensorflow

echo "\n\n\nDownloading GPT_Vuln-analyzer\n"
sudo git clone https://github.com/morpheuslord/GPT_Vuln-analyzer.git /opt/_not_installed/GPT_Vuln-analyzer

echo "\n\n\nDownloading TheFatRat\n"
sudo git clone https://github.com/Screetsec/TheFatRat.git /opt/_not_installed/thefatrat

echo "\n\n\nDownloading OneForAll\n"
sudo git clone https://github.com/shmilylty/OneForAll.git /opt/_not_installed/oneforall

echo "\n\n\nDownloading Cr3dOv3r\n"
sudo git clone https://github.com/D4Vinci/Cr3dOv3r.git /opt/_not_installed/cr3dOv3r

echo "\n\n\nDownloading Empire\n"
sudo git clone https://github.com/BC-SECURITY/Empire.git /opt/_not_installed/empire

echo "\n\n\nDownloading Sudomy\n"
sudo git clone --recursive https://github.com/screetsec/Sudomy.git /opt/_not_installed/Sudomy

echo "\n\n\nDownloading SpookFlare\n"
sudo git clone https://github.com/hlldz/SpookFlare.git /opt/_not_installed/spookflare

echo "\n\n\nDownloading Unicorn\n"
sudo git clone https://github.com/trustedsec/unicorn.git /opt/_not_installed/unicorn

echo "\n\n\nDownloading Cuteit\n"
sudo git clone https://github.com/D4Vinci/Cuteit.git /opt/cuteit

echo "\n\n\nDownloading Cloakify\n"
sudo git clone https://github.com/TryCatchHCF/Cloakify.git /opt/_not_installed/cloakify

echo "\n\n\nDownloading CHAOS\n"
sudo git clone https://github.com/tiagorlampert/CHAOS.git /opt/_not_installed/chaos
# Run
# PORT=8080 DATABASE_NAME=chaos go run cmd/chaos/main.go
# /opt/CHAOS/client/main.go
# After running go to http://localhost:8080 and login with the default username: ***admin*** and password: ***changeme***.

echo "\n\n\nDownloading Sublist3r\n"
sudo git clone https://github.com/aboul3la/Sublist3r.git /opt/_not_installed/sublister

echo "\n\n\nDownloading msfpc\n"
sudo git clone https://github.com/g0tmi1k/msfpc /opt/_not_installed/msfvenom-payload-creator

echo "\n\n\nDownloading recon-ninja\n"
git clone https://github.com/tess-ss/recon-ninja.git /opt/_not_installed/recon-ninja

echo "\n\n\nDownloading gmailc2\n"
git clone  https://github.com/ryanmrestivo/gmailc2.git /opt/_not_installed/gmailc2

echo "\n\n\nDownloading Remot3d\n"
sudo git clone https://github.com/KeepWannabe/Remot3d.git /opt/remot3d

echo "\n\n\n Downloading - r00t-3xp10it/resource_files (mosquito) \n"
# https://github.com/r00t-3xp10it/resource_files
git clone  https://github.com/r00t-3xp10it/resource_files /opt/_not_installed/mosquito
# cd mosquito & find ./ -name "*.sh" -exec chmod +x {} \;

#Interactive installs

echo "\n\n\nInstalling Veil-Framework\n"
sudo git clone https://github.com/Veil-Framework/Veil.git /opt/Veil
cd /opt/Veil/config/
./setup.sh --force --silent
sudo apt -q -y install veil

echo "\n\n\nInstalling discover\n"
sudo git clone https://github.com/leebaird/discover /opt/discover/
cd /opt/discover/
./update.sh

echo "\n\n\nInstalling reconftw\n"
sudo git clone https://github.com/six2dez/reconftw.git /opt/reconftw
cd /opt/reconftw
./install.sh

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
echo "\n\n\nDownloading bookmarks from tl-osint\n"
wget -O /home/kali/Desktop/bookmarks.html https://raw.githubusercontent.com/tracelabs/tlosint-live/master/bookmarks.html

# get nmap-bootstrap-xsl
echo "\n\n\nDownloading nmap-bootstrap-xsl\n"
git clone https://github.com/ryanmrestivo/nmap-bootstrap-xsl.git /home/kali/Desktop/

# Create symbolic links
echo "\n\n\nCreating symbolic links\n"
ln -s /opt/ /home/kali/Desktop/opt
ln -s /opt/_not_installed /home/kali/Desktop/opt/_not_installed

# Setup file structures
echo "\n\n\nSetting permissions\n"
sudo chmod -R 755 /opt

find /home/kali/Desktop/kali-setup/Desktop/ -type f -exec mv {} ~/Desktop \;
rm -rf /home/kali/Desktop/kali-setup/Desktop/

find /home/kali/Desktop/kali-setup/Wallpapers/  -type f -exec mv {} ~/Desktop \;
rm -rf /home/kali/Desktop/kali-setup/Wallpapers/

mv /home/kali/Desktop/kali-setup/setup.sh ~/Desktop

# Docker setup
docker volume create portainer_data
sudo systemctl enable docker --now

# Cleanup
echo "\n\n\nCleaning up and running final update checks\n"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Removing unnecessary directories
echo "\n\n\nRemoving unnecessary directories\n"
sudo rm -rf /opt/google
sudo rm -rf /opt/requests

# Reboot prompt
echo "\n\n\nFinished! The system will reboot in 60 seconds!\n"
echo "\n\n\nFinished! The system will reboot in 60 seconds!\n"
echo "\n\n\nFinished! The system will reboot in 60 seconds!\n"
sleep 60
sudo reboot