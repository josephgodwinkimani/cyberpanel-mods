#!/bin/bash

# This script is provided as-is, and you use it at your own risk. 
# The authors and contributors disclaim any warranties, express or implied, 
# and are not liable for any damages or losses resulting from the use of this script.

if [ ${EUID} -ne 0 ]; then
    echo "Please run as root or sudo user"
    exit 1
fi

# Set the log file path
LOG_FILE="/var/log/uninstallLogs.txt"

# Function to log messages
log_message() {
    local timestamp="$(date +'%m.%d.%Y_%H-%M-%S')"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to run commands without exiting on failure
run_command() {
    local command="$1"
    if eval "$command"; then
        log_message "Successfully ran: $command"
    else
        log_message "[WARNING] Failed to run: $command"
    fi
}

# Check if SELinux is disabled
if [ -x "$(command -v sestatus)" ]; then
    if ! sestatus | grep -q "disabled\|permissive"; then
        log_message "SELinux is enabled, disabling it..."
        run_command "setenforce 0"
        run_command "sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config"
        log_message "SELinux has been disabled. You may need to reboot the system for the changes to take effect."
    fi
fi

# Determine the distribution
detect_distribution() {
    if [ -f "/etc/lsb-release" ]; then
        echo "ubuntu"
    elif [ -f "/etc/redhat-release" ]; then
        if grep -q "CentOS Linux release 8" "/etc/redhat-release"; then
            echo "cent8"
        else
            echo "centos"
        fi
    elif [ -f "/etc/openEuler-release" ]; then
        echo "openeuler"
    else
        log_message "[ERROR] Unable to determine the distribution."
        exit 1
    fi
}

DISTRO=$(detect_distribution)

# Remove Gunicorn files if they exist
log_message "Removing Gunicorn files..."
files_to_remove=( "/etc/systemd/system/gunicorn.service" "/etc/systemd/system/gunicorn.socket" "/etc/tmpfiles.d/gunicorn.conf" )
for file in "${files_to_remove[@]}"; do
    run_command "rm -f $file"
done

# Uninstall OpenLiteSpeed without rc-uninst.sh 
log_message "Uninstalling OpenLiteSpeed..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "service lsws stop && yum remove openlitespeed -y" ;;
    cent8|openeuler) 
        run_command "service lsws stop && dnf remove openlitespeed -y" ;;
    ubuntu) 
        run_command "service lsws stop && DEBIAN_FRONTEND=noninteractive apt purge openlitespeed -y" ;;
esac

# Clean up OpenLiteSpeed directory if it exists
log_message "Cleaning up OpenLiteSpeed directory..."
if [ -d "/usr/local/lsws" ]; then
    run_command "rm -rf /usr/local/lsws"
fi

# Uninstall PowerDNS safely with checks for service existence
log_message "Uninstalling PowerDNS..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "yum remove pdns pdns-backend-mysql -y" ;;
    cent8|openeuler) 
        run_command "dnf remove pdns pdns-backend-mysql -y" ;;
    ubuntu) 
        run_command "DEBIAN_FRONTEND=noninteractive apt purge pdns-server pdns-backend-mysql -y" ;;
esac

if systemctl list-units --type=service | grep -q "pdns.service"; then
    run_command "systemctl disable pdns.service"
    run_command "systemctl stop pdns.service"
fi

# Remove PowerDNS configuration files if they exist
if [ -d "/etc/powerdns" ] || [ -d "/etc/pdns" ]; then 
    run_command "rm -rf /etc/powerdns /etc/pdns"
fi 

# Restore original resolv.conf if it was renamed 
if [ -f "/etc/resolved.conf" ]; then 
    run_command "mv /etc/resolved.conf /etc/resolv.conf"
fi 

# Enable and start systemd-resolved if it was stopped 
run_command "systemctl enable systemd-resolved.service 2>/dev/null || true"
run_command "systemctl start systemd-resolved.service 2>/dev/null || true"

# Uninstall Docker 
log_message "Uninstalling Docker..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "service docker stop || true && yum remove docker-ce docker-ce-cli containerd.io docker-compose-plugin -y" ;;
    cent8|openeuler) 
        run_command "systemctl stop docker || true && dnf remove docker-ce docker-ce-cli containerd.io docker-compose-plugin -y" ;;
    ubuntu) 
        run_command "systemctl stop docker || true && apt remove docker-ce docker-ce-cli containerd.io -y" ;;
esac

# Uninstall Pure-FTPd 
log_message "Uninstalling Pure-FTPd..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "yum remove pure-ftpd -y" ;;
    cent8|openeuler) 
        run_command "dnf remove pure-ftpd -y" ;;
    ubuntu) 
        run_command "DEBIAN_FRONTEND=noninteractive apt purge pure-ftpd-mysql -y" ;;
esac

# Disable and stop the Pure-FTPD service if it exists 
if systemctl list-units --type=service | grep -q "pure-ftpd.service"; then 
    run_command "systemctl disable pure-ftpd.service 2>/dev/null || true"
    run_command "systemctl stop pure-ftpd.service 2>/dev/null || true"
fi 

# Remove FTP user and group if they exist 
log_message "Removing Pure-FTPd user and group..."
run_command "userdel ftpuser 2>/dev/null || true"
run_command "groupdel ftpgroup 2>/dev/null || true"

# Uninstall MariaDB 
log_message "Uninstalling MariaDB..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "yum remove --remove-leaves mariadb-server mariadb -y && rm /etc/yum.repos.d/mariadb.repo";;
    cent8|openeuler) 
        run_command "dnf remove mariadb-server mariadb-client -y && dnf module reset mariadb -y";;
    ubuntu) 
        run_command "DEBIAN_FRONTEND=noninteractive apt remove mariadb-server mariadb-client -y && rm /etc/apt/sources.list.d/mariadb.sources";;
esac

# Uninstall Redis 
log_message "Uninstalling Redis..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "yum remove redis -y";;
    cent8|openeuler) 
        run_command "service redis stop && dnf remove redis -y";;
    ubuntu) 
        run_command "systemctl disable redis && DEBIAN_FRONTEND=noninteractive apt purge redis-server -y";;
esac

# Uninstall Postfix 
log_message "Uninstalling Postfix..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "yum remove --remove-leaves postfix -y";;
    cent8|openeuler) 
        run_command "dnf remove postfix -y";;
    ubuntu) 
        run_command "DEBIAN_FRONTEND=noninteractive apt purge postfix -y";;
esac

# Uninstall Dovecot 
log_message "Uninstalling Dovecot..."
case "$DISTRO" in 
    centos|cent7) 
        run_command "yum remove dovecot dovecot-mysql dovecot-pgsql dovecot-lmtpd dovecot-pigeonhole -y";;
    cent8|openeuler) 
        run_command "dnf remove dovecot dovecot-mysql dovecot-pgsql dovecot-lmtpd dovecot-pigeonhole -y";;
    ubuntu) 
        run_command "DEBIAN_FRONTEND=noninteractive apt remove dovecot-core dovecot-imapd dovecot-pop3d -y";;
esac

# Clean up files and directories  
log_message "Cleaning up files and directories..."  
run_command "rm -rf /usr/local/CyberPanel /usr/local/CyberCP"

# Clear all log files in /var/log/ except /var/log/uninstallLogs.txt  
log_message "Clearing log files in /var/log/ except uninstallLogs.txt..."  
run_command "find /var/log/ -type f ! -name 'uninstallLogs.txt' -delete"

# Remove users and groups  
log_message "Removing users and groups..."  
run_command "userdel cyberpanel 2>/dev/null || true"

# Uninstallation completed successfully.
log_message "[INFO] Uninstallation completed successfully."
echo "
==============================================================================================================
Uninstallation completed successfully.
==============================================================================================================
"
