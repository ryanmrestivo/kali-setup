#!/usr/bin/env bash
tput setaf 5;echo "##############################"
tput setaf 5;echo "#        Updates only        #"
tput setaf 5;echo "##############################"

echo "[+] Update + Upgrade System.."
sudo apt update -qq 
sudo apt upgrade -qq -y
sudo npm install npm@latest -g
sudo npm update -g

echo "[+] Upgrading Kali version to latest..."
sudo apt dist-upgrade -qq -y
sudo apt full-upgrade -qq -y

echo "[+] 202x.x OVA fixup..."

# Fix: ORIG_HEAD broken reference
sudo find /usr/share/ -name ORIG_HEAD -size -1b -delete