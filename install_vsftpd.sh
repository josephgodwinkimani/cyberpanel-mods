#!/bin/bash

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e
log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Remove pure-ftpd ..."
if pure-ftpd --help | head -1; then
    sudo apt-get autoremove pure-ftpd -y
    sudo apt-get purge pure-ftpd -y
      if ls /etc/pure-ftpd; then
        sudo rm -r /etc/pure-ftpd
      fi
    sudo killall -u ftpuser
    sudo userdel -f ftpuser
    sudo groupdel ftpgroup
fi

log_info "Install Very secure FTP daemon ..."
sudo apt install vsftpd
sudo adduser ftpuser
echo "DenyUsers ftpuser" >> /etc/ssh/sshd_config
sudo service sshd restart

log_info "Create FTP user ..."
sudo addgroup ftpgroup
sudo usermod -d /home ftpuser
sudo usermod -g ftpgroup ftpuser
# sudo chown -R ftpuser:ftpuser /home
sudo apt install acl -y
setfacl -R -m u:ftpuser:rwx /home
echo "ftpuser can upload and download any files under /home"

log_info "Install ssl certificate for ftp ..."
mkdir /etc/ssl/private
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

sudo systemctl restart vsftpd
sudo systemctl status vsftpd
echo "##########################"
echo "vsftpd installed successfully"
echo "##########################"
