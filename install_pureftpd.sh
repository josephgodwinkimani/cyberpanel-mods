#!/bin/bash

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e
log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

DISTRO=`cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+"`

if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "almalinux" ]; then
   echo "Your operating system is $DISTRO"
   echo "Sorry this is not for you"
fi

log_info "Install pure-ftpd ..."
sudo apt-get install pure-ftpd -y    
sudo groupadd ftpgroup
sudo useradd -g ftpgroup -d /dev/null -s /etc ftpuser
sudo systemctl status pure-ftpd

echo "##########################"
echo "Pure-FTPd installed successfully"
echo "##########################"
echo "Run the command as sudo-user => sudo pure-pw useradd myuser -u ftpuser -d /home/mydomain.com"
