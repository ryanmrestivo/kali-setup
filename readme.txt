# Kali Linux Setup Script

This repository contains a script designed to automate the setup of Kali Linux with essential tools and configurations. It's born out of frustration with existing repositories and aims to provide a more reliable and comprehensive setup for Kali Linux users.

## Prerequisites

- Root access

## Installation

1. Open terminal as root.
2. Install pip by running the following command:
	python install get-pip.py
3. Download and execute the setup script with the following command:
	wget https://raw.githubusercontent.com/ryanmrestivo/kali-setup/kali_setup.sh -O /home/kali/Desktop/ && chmod 777 kali_setup.sh && ./kali_setup.sh

## Usage

1. Once installed, use the 'tree' command to list files in a directory in a tree-like structure.
2. Use 'htop' for an interactive text-mode process viewer.
3. ... (additional usage instructions)

## Troubleshooting

- If you encounter an error with the update script, type `dos2unix [filename]` in the terminal.
- If you receive notifications from Metasploit regarding a minimal distribution, type `sudo tasksel` and use the space bar to add/remove packages.

## Contributing

Contributions are welcome!

## Contact

For more information or support, please contact at my email on my GitHub profile page.