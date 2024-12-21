#!/bin/bash

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

detect_os() {
  if [ -f /etc/os-release ]; then
    OS_ID=$(grep "^ID=" /etc/os-release | cut -d '=' -f 2- | tr -d '"')
  elif [ -f /etc/*-release ]; then
    OS_ID=$(cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+")
  fi

  case $OS_ID in
    "ubuntu")
      PKG_MANAGER="apt"
      SERVICE_MANAGER="systemctl"
      ;;
    "centos" | "almalinux" | "rhel")
      PKG_MANAGER="dnf"
      SERVICE_MANAGER="systemctl"
      ;;
    *)
      echo "Unsupported operating system: $OS_ID"
      exit 1
      ;;
  esac
}

# Check if WP-CLI is already installed
if command -v wp &> /dev/null; then
  log_info "WP-CLI is already installed. No need to install again. Bye!"
  exit 0
fi

detect_os

log_info "Check if php-cli is installed..."
if [ "$PKG_MANAGER" = "apt" ]; then
  # Check for lsphp packages on Ubuntu/Debian
  lsphp_packages=$(sudo apt-cache search lsphp | grep lsphp | awk '{print $1}')
  for package in $lsphp_packages; do
    if sudo dpkg -L $package | grep -q "lsphp[0-9]+/bin/lsphp"; then
      log_info "lsphp-cli found: $package"
    fi
  done
  if [ -z "$lsphp_packages" ]; then
    log_info "lsphp-cli not found. Installing php-cli..."
    sudo apt update
    sudo apt install -y php-cli
  fi
elif [ "$PKG_MANAGER" = "dnf" ]; then
  # Check for lsphp packages on CentOS/AlmaLinux
  lsphp_packages=$(sudo dnf search lsphp | grep lsphp | awk '{print $1}')
  for package in $lsphp_packages; do
    if sudo dnf repoquery -l $package | grep -q "lsphp[0-9]+/bin/lsphp"; then
      log_info "lsphp-cli found: $package"
    fi
  done
  if [ -z "$lsphp_packages" ]; then
    log_info "lsphp-cli not found. Installing php-cli..."
    sudo dnf install -y php-cli
  fi
fi

# Download WP-CLI
log_info "Download WP-CLI..."
cd /opt
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Check if WP-CLI is working
log_info "Check if WP-CLI is working..."
php wp-cli.phar --info

# Make the file executable and move it to /usr/local/bin/
log_info "Make WP-CLI executable and move to /usr/local/bin/..."
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Verify WP-CLI installation
log_info "Verify WP-CLI installation..."
wp --info

echo "##########################"
echo "WP-CLI installed successfully"
echo "##########################"
echo "You can now use WP-CLI by typing 'wp' in your terminal."
