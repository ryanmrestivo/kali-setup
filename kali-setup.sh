# Kali Setup   

# Global Theme -> Get New Global Themes -> Sort by Rating -> Sweet KDE

# Make sure file has needed perms
# chmod +x Kali_Setup.sh

#Prevent linux from going to sleep
#power manager -> display -> slide everything left to "never"

# Metasploit notes...  Armitage is broken on Kali 2021.x
#wget https://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run && wget https://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run.sha1 && echo $(cat metasploit-latest-linux-x64-installer.run.sha1)'  'metasploit-latest-linux-x64-installer.run > metasploit-latest-linux-x64-installer.run.sha1 && shasum -c metasploit-latest-linux-x64-installer.run.sha1 && chmod +x ./metasploit-latest-linux-x64-installer.run && sudo ./metasploit-latest-linux-x64-installer.run
# port 3790?
# if wget failed makes sure you are using wget-ssl
# if install hangs at 100% run: "sudo bash /opt/metasploit/ctlscript.sh restart"
# MSF_DATABASE_CONFIG=/opt/metasploit-framework/database.yml
# "database.yml" should go directly into "metasploit-framework". Also in terminal type the command line: MSF_DATABASE_CONFIG=/opt/metasploit-framework/database.yml
# Also make sure you go into a file called "profile" its in root/etc/profile. Profile is a text document, at the bottom add the line:
# export MSF_DATABASE_CONFIG=/opt/metasploit-framework/database.yml

echo "\n\n\n System Update & Setup"

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
echo ..
echo ...
echo ....
echo ...
echo ..
echo "\n\n\n Quiet update + minimal interaction to prevent bugs."
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
sudo -E apt -y update
yes | sudo apt upgrade
python3 -m pip install --upgrade pip
sudo -E apt-get -y autoclean
ln -s /opt/ /home/kali/Desktop/opt

# Add search cache
sudo apt-cache search kali

# Install Git - Should already be installed
echo "\n\n\n Installing - Git \n"
sudo apt-get install -y git 

# Install Perl
echo "\n\n\n Installing - perl \n"
sudo apt-get install -y perl  

# Install Go - https://golang.org/doc/install
echo "\n\n\n Installing - Go \n"
sudo wget -P /opt/https://golang.org/dl/go1.16.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf /opt/sys_tool_install/go1.16.linux-amd64.tar.gz
sudo export GOPATH=$HOME/go
sudo export PATH=$PATH:/usr/local/go/bin
rm go1.16.linux-amd64.tar.gz


# Basic/Other Tools Install

echo "\n\n\n Installing - Basic/Other Tools \n"
sudo apt-get install -y docker.io
docker volume create portainer_data
sudo systemctl enable docker --now
sudo apt-get install -y tree
sudo apt-get install -y htop
sudo apt-get install -y bleachbit
pip install pipenv
pip3 install name-that-hash
pip3 install search-that-hash
python2 -m pip install pipenv
python3 -m pip install pipenv
python3 -m pip install mitmproxy
sudo apt-get install -y gdu

# Install searchsploit
echo "\n\n\n Installing - searchsploit \n"
sudo apt update && sudo apt -y install exploitdb
echo "\n\n\n Installing - upgrading \n"
searchsploit -u

# Install AutoRecon - https://github.com/Tib3rius/AutoRecon#installation
echo "\n\n\n Installing - Beta AutoRecon \n"
git clone --branch beta https://github.com/Tib3rius/AutoRecon /opt/autorecon
cd /opt/Autorecon
sudo git pull
sudo checkout beta
sudo python3 -m pip install -r requirements.txt

# Install nmapAutomator - https://github.com/21y4d/nmapAutomator
echo "\n\n\n Installing - nmapAutomator \n"
cd /opt/
sudo git clone https://github.com/21y4d/nmapAutomator.git /opt/nmapautomator/
# Creates a Symbolic Link to the file so you can call it from anywhere
sudo ln -s /opt/nmapautomator/nmapAutomator.sh /usr/local/bin/

# Install Reconbot - https://github.com/0bs3ssi0n/Reconbot
echo "\n\n\n Installing - Reconbot \n"
cd /opt/
sudo git clone https://github.com/0bs3ssi0n/Reconbot /opt/reconbot/
# Creates a Symbolic Link to the file so you can call it from anywhere
sudo ln -s /opt/reconbot/reconbot.sh /usr/local/bin/

echo "\n\n\n Downloading - J3ssie/metabigor \n"
# https://github.com/j3ssie/metabigor
git clone  https://github.com/j3ssie/metabigor.git /opt/metabigor

echo "\n\n\n Downloading - streetsec/Sudomy \n"
# https://github.com/screetsec/Sudomy
git clone https://github.com/screetsec/Sudomy.git /opt/sudomy

echo "\n\n\n Downloading - nahamsec/lazyrecon \n"
# https://github.com/nahamsec/lazyrecon
git clone https://github.com/nahamsec/lazyrecon.git /opt/lazyrecon

echo "\n\n\n Downloading - trustedsec/unicorn \n"
# https://github.com/trustedsec/unicorn
git clone https://github.com/trustedsec/unicorn.git /opt/unicorn

echo "\n\n\n Downloading - D4Vinci/Cuteit \n"
# https://github.com/D4Vinci/Cuteit
git clone https://github.com/D4Vinci/Cuteit.git /opt/cuteit

echo "\n\n\n Downloading - TryCatchHCF/Cloakify \n"
# https://github.com/TryCatchHCF/Cloakify
git clone https://github.com/TryCatchHCF/Cloakify.git /opt/cloakify

echo "\n\n\n Downloading - Tuhinshubhra/RED_HAWK \n"
# https://github.com/Tuhinshubhra/RED_HAWK
git clone https://github.com/Tuhinshubhra/RED_HAWK.git /opt/redhawk

echo "\n\n\n Downloading - tiagorlampert/CHAOS \n"
# https://github.com/tiagorlampert/CHAOS
git clone https://github.com/tiagorlampert/CHAOS.git /opt/chaos

echo "\n\n\n Downloading - aboul3la/Sublist3r \n"
# https://github.com/aboul3la/Sublist3r
git clone https://github.com/aboul3la/Sublist3r.git /opt/sublister


sudo git clone https://github.com/g0tmi1k/msfpc /opt/msfvenom-payload-creator
# https://github.com/g0tmi1k/msfpc
curl -k -L "https://raw.githubusercontent.com/g0tmi1k/mpc/master/msfpc.sh" > /usr/local/bin/msfpc
chmod 0755 /usr/local/bin/msfpc

echo "\n\n\n Downloading - Gr1mmie/sumrecon \n"
# https://github.com/Gr1mmie/sumrecon
sudo git clone https://github.com/Gr1mmie/sumrecon.git /opt/sumrecon

echo "\n\n\n Downloading - danielmiessler/SecLists \n"
# https://github.com/danielmiessler/SecLists
sudo git clone https://github.com/danielmiessler/SecLists /opt/seclists

echo "\n\n\n Downloading - pwncat \n"
# https://github.com/calebstewart/pwncat
sudo pip install git+https://github.com/calebstewart/pwncat.git

echo "\n\n\n Downloading - r00t-3xp10it/resource_files (mosquito) \n"
# https://github.com/r00t-3xp10it/resource_files
sudo git clone  https://github.com/r00t-3xp10it/resource_files /opt/mosquito
cd mosquito && find ./ -name "*.sh" -exec chmod +x {} \;

echo "\n\n\n Downloading - One-Lin3r \n"
# https://github.com/D4Vinci/One-Lin3r
# one-lin3r -h
sudo git clone https://github.com/D4Vinci/One-Lin3r.git /opt/one-liner
pip install one-lin3r

echo "\n\n\n Downloading - tomnomnom/assetfinder \n"
go get -u github.com/tomnomnom/assetfinder

echo "\n\n\n Installing - m4ll0k/takeover \n"
git clone https://github.com/m4ll0k/takeover.git /opt/takeover
cd /opt/takeover
python3 setup.py install

echo "\n\n\n Installing - ristocratos/bashtop \n"
git clone https://github.com/aristocratos/bashtop.git /opt/bashtop
cd /opt/bashtop/DEB
./build

echo "\n\n\n Installing - darkoperator/dnsrecon \n"
git clone https://github.com/darkoperator/dnsrecon.git /opt/dnsrecon
cd /opt/dnsrecon/
pip3 install -r requirements.txt

echo "\n\n\n Installing - elceef/dnstwist \n"
git clone https://github.com/elceef/dnstwist.git /opt/dnstwist
apt -y install python3-dnspython python3-geoip python3-whois python3-requests python3-ssdeep 
cd /opt/dnstwist/
pip3 install -r requirements.txt

echo "\n\n\n Installing - threatexpress/domainhunter \n"
git clone https://github.com/threatexpress/domainhunter.git /opt/domain-hunter
cd /opt/domain-hunter/
pip3 install -r requirements.txt
chmod 755 domainhunter.py	

echo "\n\n\n Installing - Veil-Framework/Veil \n"
git clone https://github.com/Veil-Framework/Veil.git /opt/Veil
cd /opt/Veil/config/
./setup.sh --force --silent
apt -y install veil	

echo "\n\n\n Installing - hlldz/SpookFlare \n"
git clone https://github.com/hlldz/SpookFlare.git /opt/spookflare
cd /opt/spookflare
pip install -r requirements.txt

echo "\n\n\n Installing - peterpt/eternal_scanner \n"
git clone https://github.com/peterpt/eternal_scanner.git /opt/eternalscanner
cd /opt/eternalscanner
apt install masscan wget python-pip python-crypto python-impacket python-pyasn1-modules netcat
pip install crypto && pip install impacket && pip install pyasn1-modules
chmod +x escan
	
echo "\n\n\n Installing - robotshell/magicRecon.git \n"
git clone https://github.com/robotshell/magicRecon.git /opt/magicrecon
cd /opt/magicrecon
chmod +x install.sh
./install.sh

echo "\n\n\n Installing - Cyb0r9/ispy.git \n"
git clone https://github.com/Cyb0r9/ispy.git /opt/ispy
cd /opt/ispy
chmod +x setup.sh
chmod +x ispy

echo "\n\n\n Installing - skavngr/rapidscan.git \n"
git clone https://github.com/skavngr/rapidscan.git /opt/rapidscan
cd /opt/rapidscan
chmod +x rapidscan.py

echo "\n\n\n Installing - leebaird/discover.git \n"
git clone https://github.com/leebaird/discover.git /opt/discover
cd /opt/discover/
./update.sh

echo "\n\n\n Installing - trimstray/sandmap \n"
git clone https://github.com/trimstray/sandmap.git /opt/sandmap
cd /opt/sandmap
apt -y install xterm
chmod +x setup.sh
./setup.sh install

echo "\n\n\n Installing - smicallef/spiderfoot \n"
git clone https://github.com/smicallef/spiderfoot.git /opt/spiderfoot
cd /opt/spiderfoot
pip3 install -r requirements.txt

echo "\n\n\n Installing - smicallef/spiderfoot \n"
git clone https://github.com/smicallef/spiderfoot.git /opt/mosquito
cd /opt/mosquito
git clone https://github.com/r00t-3xp10it/resource_files.git
./mosquito.sh -i

echo "\n\n\n Installing - Gr1mmie/sumrecon \n"
git clone https://github.com/VainlyStrain/Vailyn.git /opt/Vailyn
cd /opt/Vailyn
pip install -r requirements.txt 

echo "\n\n\n Installing - 21y4d/nmapAutomator \n"
git clone https://github.com/21y4d/nmapAutomator.git /opt/nmapAutomator

echo "\n\n\n Installing - saeeddhqan/Maryam \n"
git clone https://github.com/saeeddhqan/Maryam.git /opt/maryam
cd /opt/maryam
pip install maryam

echo "\n\n\n Installing - KeepWannabe/Remot3d \n"
git clone https://github.com/KeepWannabe/Remot3d.git /opt/Remot3d
cd /opt/Remot3d
chmod +x setup.sh
./setup.sh
chmod +x Remot3d.sh

echo "\n\n\n Installing - byt3bl33d3r/SILENTTRINITY \n"
git clone https://github.com/byt3bl33d3r/SILENTTRINITY.git /opt/SilentTrinity
/opt/SilentTrinity
pip3 install -r requirements.txt
pip3 install --user pipenv && pipenv install

echo "\n\n\n Installing - scipag/vulscan \n"
git clone https://github.com/scipag/vulscan.git /opt/vulscan
ln -s `pwd`/vulscan /usr/share/nmap/scripts/vulscan
# may need to change directory, will test.  See shortcuts for commands.

echo "\n\n\n Installing - 1N3/Sn1per \n"
git clone https://github.com/1N3/Sn1per.git /opt/sniper
cd /opt/Sn1per
chmod +x install.sh
./install.sh

echo "\n\n\n Installing - j3ssie/Osmedeus \n"
git clone https://github.com/j3ssie/Osmedeus.git /opt/Osmedeus
cd /opt/Osmedeus/
./install.sh

echo "\n\n\n Installing - 0xinfection/tidos-framework \n"
# cd /opt/Osmedeus && python3 Osmedeus.py
git clone https://github.com/0xinfection/tidos-framework.git /opt/TIDoS-Framework
cd /opt/TIDoS-Framework
apt -y install libncurses5 libxml2 nmap tcpdump libexiv2-dev buildssential python3-pip libmariadbclient18 libmysqlclient-dev tor konsole
pip3 install -r requirements.txt

echo "\n\n\n Installing - Yukinoshita47/Yuki-Chan-The-Auto-Pentest \n"
git clone https://github.com/Yukinoshita47/Yuki-Chan-The-Auto-Pentest.git /opt/Yuki-Chan-The-Auto-Pentest
cd /opt/Yuki-Chan-The-Auto-Pentest
chmod 777 wafninja joomscan install-perl-module.sh yuki.sh
chmod 777 Module/WhatWeb/whatweb
pip install -r requirements.txt
./install-perl-module.sh
  
echo "\n\n\n Installing - securethelogs/Exnoscan \n"  
git clone https://github.com/securethelogs/Exnoscan.git /opt/exnoscan
cd /opt/exnoscan
chmod +x exnoscan.sh
./exnoscan.sh

echo "\n\n\n Installing - alexandreborges/malwoverview \n"
git clone https://github.com/alexandreborges/malwoverview.git /opt/malwoverview
cd /opt/malwoverview
pip install -r requirements.txt
# cd /usr/local/bin/ && python3 malwoverview.py

echo "\n\n\n Installing - Screetsec/TheFatRat \n"
git clone https://github.com/Screetsec/TheFatRat.git /opt/thefatrat
cd /opt/thefatrat
chmod +x setup.sh
./setup.sh
chmod +x fatrat

echo "\n\n\n Installing - shmilylty/OneForAll \n"
git clone https://github.com/shmilylty/OneForAll.git /opt/oneforall
cd /opt/oneforall
python3 -m pip install -U pip setuptools wheel
pip3 install -r requirements.txt

echo "\n\n\n Installing - projectdiscovery/nuclei \n"
git clone https://github.com/projectdiscovery/nuclei.git /opt/nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

echo "\n\n\n Installing - D4Vinci/Cr3dOv3r \n"
git clone https://github.com/D4Vinci/Cr3dOv3r.git /opt/Cr3dOv3r
cd /opt/Cr3dOv3r
python3 -m pip install -r requirements.txt
# python3 Cr3d0v3r.py -h

echo "\n\n\n Installing - BC-SECURITY/Empire \n"
git clone https://github.com/BC-SECURITY/Empire.git /opt/Empire
cd /opt/Empire/setup/
./install.sh    

echo "\n\n\n Installing - Gr1mmie/sumrecon \n"
apt -y install libssl-dev libffi-dev python-dev buildssential
git clone https://github.com/byt3bl33d3r/CrackMapExec.git /opt/CrackMapExec
cd /opt/CrackMapExec
apt install python3.9-venv

echo "\n\n\n Installing - chvancooten/BugBountyScanner \n"
git clone https://github.com/chvancooten/BugBountyScanner.git /opt/bugbountyscanner
cd /opt/bugbountyscanner
chmod +x BugBountyScanner.sh setup.sh
./setup.sh
# ./BugBountyScanner.sh --help

echo "\n\n\n Installing - impacket \n"
sudo git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket/
cd /opt/impacket/
sudo pip install /opt/impacket/.

echo "\n\n\n Installing - eslam3kl/3klCon \n"
sudo git clone https://github.com/eslam3kl/3klCon.git /opt/3lCkon/
cd /opt/3lCkon/
chmod +x install_tools.sh
./install_tools.sh

echo "\n\n\n Unzipping RockYou \n"
gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
ln -s /usr/share/wordlists ~/Downloads/wordlists 2>/dev/null

echo "\n\n\n Setup - scipag/vulscan.git \n"
git clone https://github.com/scipag/vulscan.git /usr/share/nmap/scripts/vulscan
ln -s `pwd`/scipag_vulscan /usr/share/nmap/scripts/vulscan

echo "\n\n\n Installing - r00t-3xp10it/venom \n"
# https://github.com/r00t-3xp10it/venom
# ./venom.sh -u
git clone https://github.com/r00t-3xp10it/venom.git /opt/
cd opt/venom
sudo find ./ -name "*.sh" -exec chmod +x {} \;
sudo find ./ -name "*.py" -exec chmod +x {} \;
cd aux && sudo ./setup.sh

echo "\n\n\n Downloading - zerosum0x0/koadic \n"
# https://github.com/zerosum0x0/koadic
git clone https://github.com/zerosum0x0/koadic.git /opt/koadic

# vulsvan
# nmap -sV --script=vulscan/vulscan.nse scanme.nmap.org
# vulners
# nmap -sV --script vulners --script-args mincvss=5.0 scanme.nmap.org

# CHAOS Usage
# Run
# PORT=8080 DATABASE_NAME=chaos go run cmd/chaos/main.go
# /opt/CHAOS/client/main.go
# After running go to http://localhost:8080 and login with the default username: ***admin*** and password: ***changeme***.



# Setup Docker Tools


# docker container ls -a
# docker container management
# docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
#    --restart=always \
#    -v /var/run/docker.sock:/var/run/docker.sock \
#    -v portainer_data:/data \
#    portainer/portainer-ce:latest
# 0.0.0.0:9443 should be the default URL.

docker pull iknowjason/aria-base:latest
# docker run -ti iknowjason/aria-base:latest
docker pull shmilylty/oneforall
# docker run -it --rm shmilylty/oneforall
docker pull offensivedockerfiles/v3n0m-scanner
# docker run -it offensivedockerfiles/v3n0m-scanner
docker pull offensivedockerfiles/gitminer
# docker run -it offensivedockerfiles/gitminer
docker pull koutto/jok3r
# docker run -i -t --name jok3r-container -w /root/jok3r -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --shm-size 2g --net=host koutto/jok3r
docker pull shmilylty/oneforall
# docker run -it --rm shmilylty/oneforall
docker pull vainlystrain/tidos-framework
# docker run -it vainlystrain/tidos-framework
docker pull rustscan/rustscan
# docker run -it rustscan/rustscan

# docker image ls



# Setup File Strucutres 
sudo chmod -R 755 /opt 

# Cleanup
echo "\n\n\n Updating - RUnning FInal UPDATE CHECK! \n"
sudo apt update
sudo apt upgrade -y
sudo apt upgrade -y
sudo apt autoremove -y

sudo cd /opt/
sudo rm -rf google
sudo rm -rf requets


# Reboot Prompt

echo "\n\n\n FINISHED - REBOOTING IN 60 Seconds !\n"
echo "\n\n\n FINISHED - REBOOTING IN 60 Seconds !\n"
echo "\n\n\n FINISHED - REBOOTING IN 60 Seconds !\n"
sleep 60
reboot