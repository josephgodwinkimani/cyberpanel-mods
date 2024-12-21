#!/bin/bash

# Trap to handle exit status and print failure message if any
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

# Function to disable other firewalls before installing CSF
disable_other_firewalls() {
  log_info "Disabling other firewalls..."

  if [ -f /etc/almalinux-release ] || [ -f /etc/centos-release ]; then
    log_info "Disabling firewalld on AlmaLinux/CentOS"
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
  elif [ -f /etc/issue ] && grep -q "Ubuntu" /etc/issue; then
    log_info "Disabling ufw on Ubuntu"
    sudo ufw disable
  else
    log_info "Unknown distro, this script might not be compatible."
    exit 0
  fi

  # Check for additional firewall services (optional)
  if systemctl is_active --quiet iptables; then
    log_info "Stopping iptables..."
    sudo systemctl stop iptables
  fi
}

# Function to download and extract CSF archive
download_and_extract_csf() {
  log_info "Downloading and Extracting the CSF archive..."
  cd /usr/src

  rm -fv csf.tgz

  if ! wget https://download.configserver.com/csf.tgz; then
    log_info "Failed to download CSF archive"
    exit 1
  fi

  if ! tar -xzf csf.tgz; then
    log_info "Failed to extract CSF archive"
    exit 1
  fi

  cd csf
}

# Function to install or update CSF
install_or_update_csf() {
  download_and_extract_csf

  if ! sh install.sh; then
    log_info "Failed to install/update CSF"
    exit 1
  fi

  sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf

  if ! csf -r; then
    log_info "Failed to restart CSF"
    exit 1
  fi

  if [ -f "/etc/init.d/csf" ] || [ -f "/usr/lib/systemd/system/csf.service" ]; then
    systemctl status csf
  else
    log_info "CSF service status check failed."
  fi
}

# Main execution
disable_other_firewalls
install_or_update_csf

log_info "CSF installation or update completed."

echo "###############################################"
echo "ConfigServer installed or updated successfully"
echo "###############################################"
