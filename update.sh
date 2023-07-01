#!/usr/bin/env bash

# This script updates the package list, upgrades all the packages,
# updates npm to its latest version, and performs a distribution upgrade.

# Define a log file
LOGFILE=update_script.log

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

# Update package list
log_message "Updating package list..."
if ! sudo apt update -qq; then
    log_message "Error updating package list"
    exit 1
fi

# Upgrade all packages
log_message "Upgrading packages..."
if ! sudo apt upgrade -qq -y; then
    log_message "Error upgrading packages"
    exit 1
fi

# Update npm to latest version
log_message "Updating npm to the latest version..."
if ! sudo npm install npm@latest -g; then
    log_message "Error updating npm"
    exit 1
fi

# Update all globally installed npm packages
log_message "Updating globally installed npm packages..."
if ! sudo npm update -g; then
    log_message "Error updating globally installed npm packages"
    exit 1
fi

# Perform distribution upgrade with user confirmation
read -p "Do you want to perform a distribution upgrade? This can change critical parts of your system. [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    log_message "Performing distribution upgrade..."
    if ! sudo apt dist-upgrade -qq -y; then
        log_message "Error performing distribution upgrade"
        exit 1
    fi
    
    log_message "Performing full upgrade..."
    if ! sudo apt full-upgrade -qq -y; then
        log_message "Error performing full upgrade"
        exit 1
    fi
else
    log_message "Distribution upgrade skipped by user."
fi

log_message "Update script completed successfully."
