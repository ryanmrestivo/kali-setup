# Kali Setup   

# Global Theme -> Get New Global Themes -> Sort by Rating -> Sweet KDE

# Make sure file has needed perms
# chmod +x Kali_Setup.sh

# prepare file for execution
# dos2unix file.sh

#Prevent linux from going to sleep
#power manager -> display -> slide everything left to "never"

echo "\n\n\n System Update & Setup"

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

sudo -E apt -y update
yes | sudo apt upgrade

sudo apt-get install -y git

sudo apt-get install -y perl  

# Install Go - https://golang.org/doc/install
# echo "\n\n\n Installing - Go \n"
# sudo wget -P https://golang.org/dl/go1.16.linux-amd64.tar.gz
# mv sys_tool_install/go1.16.linux-amd64.tar.gz /opt/
# cd /opt/
# sudo tar -C /usr/local -xzf /opt/sys_tool_install/go1.16.linux-amd64.tar.gz
# sudo export GOPATH=$HOME/go
# sudo export PATH=$PATH:/usr/local/go/bin
#rm go1.16.linux-amd64.tar.gz

# Basic/Other Tools Install

echo "\n\n\n Installing - Basic/Other Tools \n"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker volume create portainer_data
sudo systemctl enable docker --now
sudo apt-get install -y tree
# The ‘tree’ command is used for listing the files of a directory in a tree-like structure.
sudo apt-get install -y htop
# htop is an interactive text-mode process viewer for Unix systems.
sudo apt-get install -y bleachbit
# BleachBit system cleaner for Windows and Linux 
sudo apt-get install -y gdu
# Fast disk usage analyzer with console interface written in Go 
pip install pipenv
pip3 install name-that-hash
pip3 install search-that-hash
python2 -m pip install pipenv
python3 -m pip install pipenv
python3 -m pip install mitmproxy
sudo apt install nodejs

# Install searchsploit
echo "\n\n\n Installing - searchsploit \n"
sudo apt update & sudo apt -y install exploitdb
echo "\n\n\n Installing - upgrading \n"
searchsploit -u

# Install AutoRecon - https://github.com/Tib3rius/AutoRecon#installation
echo "\n\n\n Installing - Beta AutoRecon \n"
git clone --branch beta https://github.com/Tib3rius/AutoRecon /opt/autorecon
cd /opt/autorecon
sudo git pull
sudo checkout beta
sudo python3 -m pip install -r requirements.txt

# Install nmapAutomator - https://github.com/21y4d/nmapAutomator
echo "\n\n\n Installing - nmapAutomator \n"
cd /opt/
git clone https://github.com/21y4d/nmapAutomator.git /opt/nmapautomator/
# Creates a Symbolic Link to the file so you can call it from anywhere
sudo ln -s /opt/nmapautomator/nmapAutomator.sh /usr/local/bin/

echo "\n\n\n Downloading - Tuhinshubhra/RED_HAWK \n"
# https://github.com/Tuhinshubhra/RED_HAWK
git clone https://github.com/Tuhinshubhra/RED_HAWK.git /opt/redhawk

echo "\n\n\n Installing - leebaird/discover \n"
git clone https://github.com/leebaird/discover /opt/discover/
cd /opt/discover/
./update.sh

echo "\n\n\n Downloading - One-Lin3r \n"
# https://github.com/D4Vinci/One-Lin3r
# one-lin3r -h
git clone https://github.com/D4Vinci/One-Lin3r.git /opt/one-liner
pip install one-lin3r

echo "\n\n\n Downloading - knassar702/scant3r \n"
# https://github.com/knassar702/scant3r
 git clone https://github.com/knassar702/scant3r /opt/scanter
 cd scant3r
 pip3 install -r requirements.txt

echo "\n\n\n Installing - m4ll0k/takeover \n"
git clone https://github.com/m4ll0k/takeover.git /opt/takeover
cd /opt/takeover
python3 setup.py install

echo "\n\n\n Installing - ristocratos/bashtop \n"
git clone https://github.com/aristocratos/bashtop.git /opt/bashtop
cd /opt/bashtop/DEB
./build

# echo "\n\n\n Installing - 0xApt/awesome-bbht \n"
# git clone https://github.com/0xApt/awesome-bbht.sh /opt/bbht
# cd bbht
# chmod +x awesome-bbht.sh

echo "\n\n\n Installing - darkoperator/dnsrecon \n"
git clone https://github.com/darkoperator/dnsrecon.git /opt/dnsrecon
cd /opt/dnsrecon/
pip3 install -r requirements.txt

echo "\n\n\n Installing - elceef/dnstwist \n"
git clone https://github.com/elceef/dnstwist.git /opt/dnstwist
apt -y install python3-dnspython python3-geoip python3-whois python3-requests python3-ssdeep 
cd /opt/dnstwist/
pip3 install -r requirements.txt

echo "\n\n\n Installing - GamehunterKaan/AutoPWN-Suite \n"
pip install autopwn-suite
# autopwn-suite -y

echo "\n\n\n Installing - Veil-Framework/Veil \n"
git clone https://github.com/Veil-Framework/Veil.git /opt/Veil
cd /opt/Veil/config/
./setup.sh --force --silent
apt -y install veil	

echo "\n\n\n Installing - peterpt/eternal_scanner \n"
git clone https://github.com/peterpt/eternal_scanner.git /opt/eternalscanner
cd /opt/eternalscanner
apt install masscan wget python-pip python-crypto python-impacket python-pyasn1-modules netcat
pip install crypto & pip install impacket & pip install pyasn1-modules
chmod +x escan

echo "\n\n\n Installing - Cyb0r9/ispy.git \n"
git clone https://github.com/Cyb0r9/ispy.git /opt/ispy
cd /opt/ispy
chmod +x setup.sh
chmod +x ispy

echo "\n\n\n Installing - skavngr/rapidscan.git \n"
git clone https://github.com/skavngr/rapidscan.git /opt/rapidscan
cd /opt/rapidscan
chmod +x rapidscan.py

echo "\n\n\n Installing - trimstray/sandmap \n"
git clone https://github.com/trimstray/sandmap.git /opt/sandmap
cd /opt/sandmap
apt -y install xterm
chmod +x setup.sh
./setup.sh install

echo "\n\n\n Installing - robotshell/magicRecon \n"
git clone https://github.com/robotshell/magicRecon /opt/magicRecon
cd /opt/magicRecon
chmod +x install.sh
./install.sh

echo "\n\n\n Installing - smicallef/spiderfoot \n"
git clone https://github.com/smicallef/spiderfoot.git /opt/spiderfoot
cd /opt/spiderfoot
pip3 install -r requirements.txt

echo "\n\n\n Installing - KeepWannabe/Remot3d \n"
git clone https://github.com/KeepWannabe/Remot3d.git /opt/remot3d
cd /opt/remot3d
chmod +x setup.sh
./setup.sh
chmod +x Remot3d.sh

# echo "\n\n\n Installing -  blacklanternsecurity/bbot \n"
pip install bbot
# https://github.com/blacklanternsecurity/bbot

echo "\n\n\n Installing - j3ssie/Osmedeus \n"
git clone https://github.com/j3ssie/Osmedeus.git /opt/osmedeus
cd /opt/osmedeus/
bash -c "$(curl -fsSL https://raw.githubusercontent.com/osmedeus/osmedeus-base/master/install.sh)"
mkdir -p $GOPATH/src/github.com/j3ssie
git clone --depth=1 https://github.com/j3ssie/osmedeus $GOPATH/src/github.com/j3ssie/osmedeus
cd $GOPATH/src/github.com/j3ssie/osmedeus
make build

echo "\n\n\n Installing - alexandreborges/malwoverview \n"
git clone https://github.com/alexandreborges/malwoverview.git /opt/malwoverview
cd /opt/malwoverview
pip install -r requirements.txt
# cd /usr/local/bin/ & python3 malwoverview.py

echo "\n\n\n Installing - projectdiscovery/nuclei \n"
git clone https://github.com/projectdiscovery/nuclei.git /opt/nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

git clone https://github.com/chvancooten/BugBountyScanner.git /opt/BugBountyScanner
cd BugBountyScanner
# cp .env.example .env # Edit accordingly
chmod +x BugBountyScanner.sh setup.sh
./setup.sh -t /custom/tools/dir # Setup is automatically triggered, but can be manually run
# ./BugBountyScanner.sh --help
# ./BugBountyScanner.sh -d target1.com -d target2.net -t /custom/tools/dir --quick

echo "\n\n\n Installing - VainlyStrain/Vailyn \n"
git clone https://github.com/VainlyStrain/Vailyn /opt/Vailyn
cd /opt/Vailyn
pip install -r requirements.txt

echo "\n\n\n Installing - eslam3kl/3klCon \n"
git clone https://github.com/eslam3kl/3klCon.git /opt/3lckon/
cd /opt/3lckon/
chmod +x install_tools.sh
./install_tools.sh
apt-get install jq nmap phantomjs npm chromium parallel
pip3 install npm
npm i -g wappalyzer wscat

echo "\n\n\n Installing - t3l3machus/hoaxshell \n"
git clone https://github.com/t3l3machus/hoaxshell /opt/hoaxshell
# https://github.com/t3l3machus/hoaxshell
cd hoaxshell
pip3 install -r requirements.txt
chmod +x hoaxshell.py

echo "\n\n\n Downloading - r00t-3xp10it/venom \n"
# https://github.com/r00t-3xp10it/venom
# ./venom.sh -u
git clone https://github.com/r00t-3xp10it/venom.git /opt/_not_installed/venom
# sudo find ./ -name "*.sh" -exec chmod +x {} \;
# sudo find ./ -name "*.py" -exec chmod +x {} \;
# cd aux & sudo ./setup.sh

echo "\n\n\n Installing - iamthefrogy/frogy \n"
git clone https://github.com/iamthefrogy/frogy.git /opt/frogy
cd /opt/frogy/ 
chmod +x install.sh
./install.sh

echo "\n\n\n Installing - R0X4R/Garud \n"
git clone https://github.com/R0X4R/Garud.git /opt/Garud 
cd /opt/Garud/
chmod +x garud 
chmod +x install.sh
mv garud /usr/bin/
./install.sh

echo "\n\n\n Installing - six2dez/reconftw \n"
git clone https://github.com/six2dez/reconftw.git /opt/reconftw
cd /opt/reconftw 
./install.sh

echo "\n\n\n Downloads to /opt/_not_installed/ \n"
echo "\n\n\n Downloads to /opt/_not_installed/ \n"
echo "\n\n\n Downloads to /opt/_not_installed/ \n"

echo "\n\n\n Downloading - sahullander/Purple-Pwny \n"
# https://github.com/sahullander/Purple-Pwny
git clone https://github.com/sahullander/Purple-Pwny.git /opt/_not_installed/Purple-Pwny
# curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall & chmod 755 msfinstall & ./msfinstall
# ./msfconsole
# pip3 install python-nmap pymetasploit3 netifaces pandas

# echo "\n\n\n Downloading - byt3bl33d3r/SILENTTRINITY \n"
git clone https://github.com/byt3bl33d3r/SILENTTRINITY.git /opt/_not_installed/silenttrinity
# pip3 install -r requirements.txt
# pip3 install --user pipenv & pipenv install

#echo "\n\n\n Downloading - scipag/vulscan \n"
git clone https://github.com/scipag/vulscan.git /opt/_not_installed/vulscan
# ln -s `pwd`/vulscan /usr/share/nmap/scripts/vulscan
# may need to change directory, will test.  See shortcuts for commands.

#echo "\n\n\n Downloading - 0xinfection/tidos-framework \n"
# cd /opt/Osmedeus & python3 Osmedeus.py
git clone https://github.com/0xinfection/tidos-framework.git /opt/_not_installed/tidos-framework
# cd /opt/tidos-framework
# apt -y install libncurses5 libxml2 nmap tcpdump libexiv2-dev buildssential python3-pip libmariadbclient18 libmysqlclient-dev tor konsole
# pip3 install -r requirements.txt

echo "\n\n\n Downloading - mazen160/shennina \n"
# https://github.com/mazen160/shennina
git clone https://github.com/mazen160/shennina.git /opt/_not_installed/shennina
pip3 install tensorflow
# pip3 install -r requirements.txt

#echo "\n\n\n Downloading - Screetsec/TheFatRat \n"
git clone https://github.com/Screetsec/TheFatRat.git /opt/_not_installed/thefatrat
# cd /opt/thefatrat
# chmod +x setup.sh
# ./setup.sh
# chmod +x fatrat

#echo "\n\n\n Downloading - shmilylty/OneForAll \n"
git clone https://github.com/shmilylty/OneForAll.git /opt/_not_installed/oneforall
# cd /opt/oneforall
# python3 -m pip install -U pip setuptools wheel
# pip3 install -r requirements.txt

#echo "\n\n\n Downloading - D4Vinci/Cr3dOv3r \n"
git clone https://github.com/D4Vinci/Cr3dOv3r.git /opt/_not_installed/cr3dOv3r
# cd /opt/cr3dOv3r
# python3 -m pip install -r requirements.txt
# python3 Cr3d0v3r.py -h

#echo "\n\n\n Downloading - BC-SECURITY/Empire \n"
git clone https://github.com/BC-SECURITY/Empire.git /opt/_not_installed/empire
# cd /opt/empire/setup/
# ./install.sh    

echo "\n\n\n Downloading - screetsec/Sudomy \n"
git clone --recursive https://github.com/screetsec/Sudomy.git /opt/_not_installed/Sudomy
# python3 -m pip install -r requirements.txt
# echo "\n\n\n Downloading - hlldz/SpookFlare \n"

git clone https://github.com/hlldz/SpookFlare.git /opt/_not_installed/spookflare
# cd /opt/spookflare
# pip install -r requirements.txt

echo "\n\n\n Downloading - trustedsec/unicorn \n"
# https://github.com/trustedsec/unicorn
git clone https://github.com/trustedsec/unicorn.git /opt/_not_installed/unicorn

echo "\n\n\n Downloading - D4Vinci/Cuteit \n"
# https://github.com/D4Vinci/Cuteit
git clone https://github.com/D4Vinci/Cuteit.git /opt/_not_installed/cuteit

echo "\n\n\n Downloading - TryCatchHCF/Cloakify \n"
# https://github.com/TryCatchHCF/Cloakify
git clone https://github.com/TryCatchHCF/Cloakify.git /opt/_not_installed/cloakify

echo "\n\n\n Downloading - tiagorlampert/CHAOS \n"
# https://github.com/tiagorlampert/CHAOS
git clone https://github.com/tiagorlampert/CHAOS.git /opt/_not_installed/chaos

echo "\n\n\n Downloading - aboul3la/Sublist3r \n"
# https://github.com/aboul3la/Sublist3r
git clone https://github.com/aboul3la/Sublist3r.git /opt/_not_installed/sublister

echo "\n\n\n Downloading - g0tmi1k/msfpc \n"
git clone https://github.com/g0tmi1k/msfpc /opt/_not_installed/msfvenom-payload-creator
# https://github.com/g0tmi1k/msfpc
# curl -k -L "https://raw.githubusercontent.com/g0tmi1k/mpc/master/msfpc.sh" > /usr/local/bin/msfpc
# chmod 0755 /usr/local/bin/msfpc

echo "\n\n\n Downloading - r00t-3xp10it/resource_files (mosquito) \n"
# https://github.com/r00t-3xp10it/resource_files
git clone  https://github.com/r00t-3xp10it/resource_files /opt/_not_installed/mosquito
# cd mosquito & find ./ -name "*.sh" -exec chmod +x {} \;

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

# docker image ls

ln -s /opt/ /home/kali/Desktop/opt
ln -s /opt/_not_installed /home/kali/Desktop/opt/_not_installed

# Setup File Strucutres 
sudo chmod -R 755 /opt 

# Cleanup
echo "\n\n\n Updating - RUNNING FINAL UPDATE CHECK! \n"
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