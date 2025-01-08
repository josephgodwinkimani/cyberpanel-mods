#!/bin/bash
# Based on https://community.cyberpanel.net/t/deploy-nodejs-app-doesnnt-work/36389/2
# This script uses n to manage Node.js versions, allowing for easy installation of specific versions.
# Using this script you can install as many Node.js versions as you wish.

# Function to detect the operating system
detect_os() {
  if [ -f /etc/os-release ]; then
    OS_ID=$(grep "^ID=" /etc/os-release | cut -d '=' -f 2- | tr -d '"')
  elif [ -f /etc/*-release ]; then
    OS_ID=$(cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+")
  fi

  case $OS_ID in
    "ubuntu")
      PKG_MANAGER="apt"
      ;;
    "centos" | "almalinux" | "rhel")
      if [ -f /etc/centos-release ] && grep -q "release 7" /etc/centos-release; then
        PKG_MANAGER="yum"
      else
        PKG_MANAGER="dnf"
      fi
      ;;
    *)
      echo "Unsupported operating system: $OS_ID"
      exit 1
      ;;
  esac
}

# Detect the operating system
detect_os

# Install Node.js based on the detected package manager
install_node() {
  case $PKG_MANAGER in
    "apt")
      sudo apt update
      sudo apt install -y nodejs npm
      ;;
    "yum")
      sudo yum install -y nodejs
      ;;
    "dnf")
      sudo dnf install -y nodejs
      ;;
  esac

  # Verify installation
  echo "Node.js version:"
  node -v
  echo "npm version:"
  npm -v
}

# Check if Node.js is already installed
if command -v node &> /dev/null; then
  # Check the installed Node.js version
  NODE_VERSION=$(node -v)
  echo "Node.js is already installed. Version: $NODE_VERSION"
else
  echo "Node.js is not installed. Installing now..."

  install_node
  
  # Clean npm cache if npm is installed
  if command -v npm &> /dev/null; then
    sudo npm cache clean -f
  fi

  # Install n globally to manage Node.js versions
  sudo npm install -g n

  # Install the latest Node.js using n
  sudo n latest

  # Reinstall nodejs using the appropriate package manager
  case $PKG_MANAGER in
    "apt")
      sudo apt update && sudo apt-get install --reinstall nodejs
      ;;
    "yum")
      sudo yum update && sudo yum reinstall nodejs
      ;;
    "dnf")
      sudo dnf update && sudo dnf reinstall nodejs
      ;;
  esac

  # Verify the Node.js version after installation
  node -v
fi

# Check if 'n' is installed and Node.js is installed, then prompt for version input
if command -v n &> /dev/null && command -v node &> /dev/null; then
  read -p "Enter the version of Node.js you want to install (e.g., v16.20.1): " REQUESTED_VERSION
  
  # Install the requested version using 'n'
  echo "Installing Node.js version $REQUESTED_VERSION..."
  sudo n "$REQUESTED_VERSION"

  # Verify the installed version
  INSTALLED_VERSION=$(node -v)
  echo "Node.js version $INSTALLED_VERSION has been installed."
fi

echo "You can run `n` to see Node.js version $NODE_VERSION is installed."

# Prompt for reboot confirmation
read -p "Do you want to reboot the system now? (yes/no): " REBOOT_CHOICE

if [[ "$REBOOT_CHOICE" == "yes" ]]; then
  echo "Rebooting the system..."
  sudo reboot
else
  echo "The system will not be rebooted."
fi
