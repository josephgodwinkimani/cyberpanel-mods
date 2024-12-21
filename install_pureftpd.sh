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
    "ubuntu" | "debian")
      PKG_MANAGER="apt"
      SERVICE_MANAGER="systemctl"
      PURE_FTPD_SERVICE="pure-ftpd"
      ;;
    "centos" | "almalinux" | "rhel" | "fedora")
      PKG_MANAGER="dnf"
      SERVICE_MANAGER="systemctl"
      PURE_FTPD_SERVICE="pure-ftpd"
      ;;
    *)
      echo "Unsupported operating system: $OS_ID"
      exit 1
      ;;
  esac
}

detect_os

log_info "Install pure-ftpd ..."
if [ "$PKG_MANAGER" = "apt" ]; then
  sudo apt update
  sudo apt install pure-ftpd -y
elif [ "$PKG_MANAGER" = "dnf" ]; then
  sudo dnf install pure-ftpd -y
fi

sudo groupadd ftpgroup
sudo useradd -g ftpgroup -d /dev/null -s /etc ftpuser

# Start and enable the service
sudo $SERVICE_MANAGER start $PURE_FTPD_SERVICE
sudo $SERVICE_MANAGER enable $PURE_FTPD_SERVICE

# Check the service status
sudo $SERVICE_MANAGER status $PURE_FTPD_SERVICE

echo "##########################"
echo "Pure-FTPd installed successfully"
echo "##########################"
echo "Run the command as sudo-user => sudo pure-pw useradd myuser -u ftpuser -d /home/mydomain.com"
