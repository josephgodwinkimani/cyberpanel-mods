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

# Function to run commands without retries
run_command() {
    local command="$1"
    if eval "$command"; then
        log_message "Successfully ran: $command"
    else
        log_message "[ERROR] Failed to run: $command"
        exit 1
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

# Uninstall OpenLiteSpeed with a check for rc-uninst.sh existence
log_message "Uninstalling OpenLiteSpeed..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
    run_command "service lsws stop && yum remove openlitespeed -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
    run_command "service lsws stop && dnf remove openlitespeed -y"
elif [ "$DISTRO" = "ubuntu" ]; then
    run_command "service lsws stop && DEBIAN_FRONTEND=noninteractive apt purge openlitespeed -y"
fi

# Check for the existence of rc-uninst.sh before running it
if [ -f "/usr/local/lsws/admin/misc/rc-uninst.sh" ]; then
    run_command "/usr/local/lsws/admin/misc/rc-uninst.sh"
else
    log_message "[WARNING] rc-uninst.sh not found; skipping this step."
fi

# Clean up OpenLiteSpeed directory if it exists
log_message "Cleaning up OpenLiteSpeed..."
if [ -d "/usr/local/lsws" ]; then
    run_command "rm -rf /usr/local/lsws"
fi

# Uninstall PowerDNS with checks for service existence and proper commands based on distro.
log_message "Uninstalling PowerDNS..."
case "$DISTRO" in 
    centos|cent7) run_command "yum remove pdns pdns-backend-mysql -y" ;;
    cent8|openeuler) run_command "dnf remove pdns pdns-backend-mysql -y" ;;
    ubuntu) run_command "DEBIAN_FRONTEND=noninteractive apt purge pdns-server pdns-backend-mysql -y" ;;
esac

# Clean up PowerDNS configuration files if they exist.
if [ -d "/etc/powerdns" ] || [ -d "/etc/pdns" ]; then 
    run_command "rm -rf /etc/powerdns /etc/pdns"
fi 

# Continue with other uninstallations similarly...

log_message "[INFO] Uninstallation completed successfully."
echo "
==============================================================================================================
Uninstallation completed successfully.
==============================================================================================================
"
