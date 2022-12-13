#!/bin/bash

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e
log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Remove pure-ftpd ..."
sudo apt-get autoremove pure-ftpd
sudo apt-get purge pure-ftpd
sudo rm -r /etc/pure-ftpd
sudo killall -u ftpuser
sudo userdel -f ftpuser
sudo groupdel ftpgroup

log_info "Install Very secure FTP daemon ..."
sudo apt install vsftpd
sudo adduser ftpuser
echo "DenyUsers ftpuser" >> /etc/ssh/sshd_config
sudo service sshd restart

log_info "Create FTP user ..."
sudo usermod -d /home ftpuser
sudo chown ftpuser:ftpuser /home

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
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
force_dot_files=YES
pasv_min_port=40000
pasv_max_port=50000
allow_writeable_chroot=YES
EOF
sudo systemctl restart vsftpd
sudo systemctl status vsftpd
echo "##########################"
echo "vsftpd installed successfully"
echo "##########################"
