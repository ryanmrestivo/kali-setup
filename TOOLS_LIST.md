# Kali Setup Tool - Installed Tools List

This file provides a categorized overview of the tools managed and installed by the Kali Setup script.

## 🕵️ Reconnaissance & OSINT (Heavy Automation)
Tools designed to perform extensive initial discovery and data gathering.

*   **BBOT:** A massive OSINT automation framework for subdomains, emails, and cloud assets.
*   **3klCon:** A comprehensive automation tool that combines multiple scanners for reconnaissance.
*   **Osmedeus:** A fully automated offensive security framework for reconnaissance and vulnerability scanning.
*   **reNgine:** An automated reconnaissance framework for web applications (Run via Docker).
*   **Spiderfoot:** An OSINT automation tool that queries over 100 public data sources.
*   **reconftw:** A script that automates the entire reconnaissance process using best-of-breed tools.

## 🔓 Leak & Credential Scanning
Tools for deep email/username footprinting and identifying breached data.

*   **Holehe:** Checks if an email is registered on 120+ social media sites and services.
*   **Maigret:** Powerful username checker that searches across 3000+ websites.
*   **h8mail:** An email OSINT and password breach hunting tool (supports many APIs).
*   **GHunt:** Investigates Google accounts using just an email address.
*   **SocialScan:** Fast tool to check email/username availability on popular platforms.
*   **EmailHarvester:** Scrapes emails from search engines and other public sources.

## 🛡️ OSCP & Exam Approved
Critical tools for the OSCP exam, focusing on manual proficiency and AD.

*   **Feroxbuster:** Extremely fast recursive content discovery (replaces DirBuster/GoBuster).
*   **NetExec:** The modern successor to CrackMapExec for network and AD exploitation.
*   **Ligolo-ng:** A high-performance pivoting tool used to tunnel through compromised systems.
*   **PEASS-ng (WinPEAS/LinPEAS):** Privilege escalation awesome scripts for Windows and Linux.
*   **BloodHound.py:** Python-based ingestor for Active Directory domain analysis.
*   **Impacket Suite:** A collection of Python classes for working with network protocols.
*   **Chisel:** A fast TCP/UDP tunnel, transported over HTTP, secured via SSH.

## 🕸️ Web Application Analysis
*   **Wappalyzer:** CLI tool to identify technologies used on websites.
*   **Nodesub:** A fast sub-domain discovery tool using various browser-based techniques.
*   **Wscat:** A command-line tool for connecting to and testing WebSockets.
*   **Nikto:** A classic web server scanner for finding dangerous files and outdated software.

## 📦 Vulnerability & Exploitation
*   **Nuclei:** A fast, template-based vulnerability scanner (managed via Go).
*   **SearchSploit:** A command-line interface for Exploit-DB to find local exploits.
*   **Autopwn-Suite:** A tool for scanning and automatically exploiting targets (Use with caution).
*   **Sliver C2:** A cross-platform implant framework (C2) for red teaming.

## 📊 System Utilities & Monitors
*   **Btop/Htop:** Modern, interactive process viewers and system monitors.
*   **GDU:** A fast disk usage analyzer with a console interface.
*   **BleachBit:** Cleans up unnecessary files to free up disk space and maintain privacy.
*   **Dos2Unix:** Converts text files between Windows and Linux line endings.
*   **Power Stability Module:** Disables screensavers and power-saving modes to ensure long-running scans are not interrupted.

## 🚀 Professional Operational Modules
*   **Hardened Firefox:** Automated browser configuration using system-wide policies. Includes auto-installation of FoxyProxy, Wappalyzer, and Cookie Editor, plus a pre-configured proxy for Burp Suite.
*   **Persistent Tunnels:** Background systemd service for Ligolo-ng, ensuring persistent pivoting capabilities.
*   **API Vault:** Centralized manager for OSINT API keys (Shodan, Censys, etc.).
