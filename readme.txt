This repository is designed to get up-and-running with some tools and configurataions that I believe should come with Kali Linux.  This setup script has been made primarily out of frustration with currently existing (broken, incomplete, poorly written) repositories available.

This setup is not completely unattended (service restarts... I'm working on it).

If you get an error with the update script go into terminal and type "dos2unix [filename]."

If you have any notifications from mestasploit regarding having a minimal distribution type "sudo tasksel" then use the "space" bar to add/remove packages.

To immediately get started and execute the full upgrade paste this into terminal as root:

python install get-pip.py

wget https://raw.githubusercontent.com/ryanmrestivo/kali-setup/kali_setup.sh -O /home/kali/Desktop/ && chmod 777 kali_setup.sh && ./kali_setup.sh

tree
# The ‘tree’ command is used for listing the files of a directory in a tree-like structure.

htop
# htop is an interactive text-mode process viewer for Unix systems.

bleachbit
# BleachBit system cleaner for Windows and Linux 

searchsploit

autopwn-suite

bbot
# OSINT automation