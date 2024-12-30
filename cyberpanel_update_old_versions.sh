#!/bin/bash

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

# Prompt the user to enter the GitHub username
read -p "Enter the GitHub username (e.g., usmannasir or josephgodwinkimani): " username

# Prompt the user to enter the version number
read -p "Enter the CyberPanel version you want to upgrade to (e.g., v2.3.8): " version

# Construct the URL using the provided username and version
url="https://raw.githubusercontent.com/$username/cyberpanel/$version/cyberpanel_upgrade.sh"

log_info "Downloading cyberpanel_upgrade.sh from $url..."
wget $url -O cyberpanel_upgrade.sh

# Check if the download was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to download the script. Please check the username and version number, and try again."
    exit 1
fi

# Make the script executable
chmod +x cyberpanel_upgrade.sh

# Execute the upgrade script
log_info "Running the upgrade script..."
./cyberpanel_upgrade.sh
