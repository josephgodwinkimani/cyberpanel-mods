#!/bin/bash
# Based on https://community.cyberpanel.net/t/deploy-nodejs-app-doesnnt-work/36389/2

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

# Check if Node.js is already installed
if command -v node &> /dev/null; then
  # Check the installed Node.js version
  NODE_VERSION=$(node -v)
  echo "Node.js is already installed. Version: $NODE_VERSION"
fi

# Clean npm cache
sudo npm cache clean -f

# Install n globally
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

# Verify the Node.js version
node -v

# Reboot the system
sudo reboot
