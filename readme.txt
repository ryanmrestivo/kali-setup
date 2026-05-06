# Kali Linux Setup (Ultimate Version)

An automated, modular, and menu-driven setup tool for Kali Linux. Designed for both general penetration testing and strict OSCP exam compliance.

## Key Features
- **TUI Menu:** Easy-to-use interface powered by `whiptail`.
- **Modular Installation:** Choose between a full setup or an OSCP-only environment.
- **Dynamic Desktop Launchers:** Automatically generates clickable, trusted desktop icons for all major tools.
- **Pentest Aliases:** Injects high-productivity aliases (e.g., `myip`, `listening`, `nxc`) into ZSH/Bash.
- **Global Command:** Access the tool from anywhere by simply typing `kali-setup`.
- **Integrated Update System:** Keeps system packages, pipx tools, Go binaries, and GitHub repos current.

## Installation

```bash
git clone https://github.com/ryanmrestivo/kali-setup.git
cd kali-setup
chmod +x kali-setup.sh update.sh
sudo ./kali-setup.sh
```

## Usage

After the first run, you can simply type:
```bash
kali-setup
```
This will bring up the main menu with the following options:
1. **Full Standard Setup:** Installs everything (APT, Python, Go, Docker, GitHub tools).
2. **OSCP-Only Setup:** Installs only exam-compliant tools.
3. **Update All Tools:** Runs the comprehensive update suite.
4. **Install Sliver C2:** Quick installation of the Sliver C2 framework.
5. **Create Desktop Icons Only:** Refreshes your desktop shortcuts.
6. **Cleanup System:** Removes unnecessary packages and clears cache.

## Tool Categories
- **Monitors:** Btop, Htop (with desktop icons).
- **AD & Lateral Movement:** NetExec, BloodHound, Impacket.
- **Pivoting:** Ligolo-ng, Chisel.
- **OSINT:** BBOT, Trace Labs bookmarks.
- **Vulnerability Analysis:** Nuclei, SearchSploit.

## Troubleshooting
Check `kali-setup.log` for execution details. Ensure you run as root for full functionality.

## Contributing
Contributions are welcome! Please follow the modular function structure.
