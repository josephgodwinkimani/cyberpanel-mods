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

detect_os

log_info "Remove pure-ftpd ..."
if command -v pure-ftpd &> /dev/null; then
  if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt-get autoremove pure-ftpd -y
    sudo apt-get purge pure-ftpd -y
  elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf remove pure-ftpd -y
  fi

  if [ -d /etc/pure-ftpd ]; then
    sudo rm -r /etc/pure-ftpd
  fi
  sudo killall -u ftpuser
  sudo userdel -f ftpuser
  sudo groupdel ftpgroup
fi

log_info "Remove vsftpd ..."
if command -v vsftpd &> /dev/null; then
  if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt-get autoremove vsftpd -y
    sudo apt-get purge --auto-remove vsftpd -y
  elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf remove vsftpd -y
  fi
fi

log_info "Install Very secure FTP daemon ..."
if [ "$PKG_MANAGER" = "apt" ]; then
  sudo apt update
  sudo apt install vsftpd
elif [ "$PKG_MANAGER" = "dnf" ]; then
  sudo dnf install vsftpd -y
fi

sudo $SERVICE_MANAGER start vsftpd
sudo $SERVICE_MANAGER enable vsftpd
cp /etc/vsftpd.conf  /etc/vsftpd.conf_default

log_info "Create FTP user ..."
echo "Choose an FTP user? (e.g testuser) "
read FTP_USER
sudo addgroup ftpgroup
sudo adduser $FTP_USER
echo "DenyUsers $FTP_USER" >> /etc/ssh/sshd_config
sudo service sshd restart

log_info "Change FTP user home directory ..."
echo "Choose an FTP user home directory? (e.g /home/mydomain.com) "
echo "This script will not create the directory for you"
read FTP_USER_HOMEDIR
sudo usermod -d $FTP_USER_HOMEDIR $FTP_USER
sudo usermod -g ftpgroup $FTP_USER
# sudo chown -R $FTP_USER:$FTP_USER $FTP_USER_HOMEDIR
if [ "$PKG_MANAGER" = "apt" ]; then
  sudo apt install acl -y
elif [ "$PKG_MANAGER" = "dnf" ]; then
  sudo dnf install acl -y
fi
setfacl -R -m u:$FTP_USER:rwx $FTP_USER_HOMEDIR
sudo $SERVICE_MANAGER restart vsftpd
echo "$FTP_USER can upload and download any files under $FTP_USER_HOMEDIR"

log_info "Create FTP user password ..."
echo "Choose an FTP user password for $FTP_USER? (e.g testuserpassword) "
read FTP_USER_PASSWORD
echo "$FTP_USER_PASSWORD" | sudo passwd --stdin $FTP_USER
sudo $SERVICE_MANAGER restart vsftpd

log_info "Install ssl certificate for ftp ..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt

log_info "Configure Very secure FTP ..."
sudo mv /etc/vsftpd.conf /etc/vsftpd.conf.bak
sudo tee /etc/vsftpd.conf <<"EOF"
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
chroot_list_file=/etc/vsftpd.chroot_list
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
force_dot_files=YES
pasv_min_port=40000
pasv_max_port=50000
allow_writeable_chroot=YES
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
ssl_tlsv1=NO
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=YES
ssl_ciphers=HIGH
rsa_cert_file=/etc/ssl/certs/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
EOF

sudo $SERVICE_MANAGER restart vsftpd
sudo $SERVICE_MANAGER status vsftpd
echo "##########################"
echo "vsftpd installed successfully"
echo "##########################"
echo "Go to /etc/vsftpd.chroot_list and add ftp user line by line to allow access"
