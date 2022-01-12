This repository is designed to get up-and-running with some tools and configurataions that I believe should come with Kali Linux.  This setup script has been made primarily out of frustration with currently existing (broken, incomplete, poorly written) repositories available.

This setup is not completely unattended (service restarts... I'm working on it).

To immediately get started and execute the full upgrade paste this into terminal as root:

wget https://raw.githubusercontent.com/ryanmrestivo/kali-setup/kali_setup.sh -O /home/kali/Desktop/ && chmod 777 kali_setup.sh && ./kali_setup.sh