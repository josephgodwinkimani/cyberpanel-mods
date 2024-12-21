#!/bin/bash
# This script is provided as-is, and you use it at your own risk. The authors and contributors disclaim any warranties, express or implied, and are not liable for any damages or losses resulting from the use of this script.

if [ ${EUID} -ne 0 ]; then
  echo "Please run as root or sudo user"
  exit 1
fi

# Set the log file path
LOG_FILE="/var/log/uninstallLogs.txt"

# Function to log messages
log_message() {
  local timestamp="$(date +'%m.%d.%Y_%H-%M-%S')"
  echo "[$timestamp] $1"
  echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to run commands with retries
run_command() {
  local command="$1"
  local retries=0
  local max_retries=3

  while [ $retries -lt $max_retries ]; do
    if $command; then
      log_message "Successfully ran: $command"
      return 0
    else
      log_message "Running $command failed. Retrying, attempt $((retries + 1)) of $max_retries"
      ((retries++))
    fi
  done

  log_message "[ERROR] Failed to run $command after $max_retries attempts. Fatal error."
  exit 1
}

# Function to ask user for confirmation
ask_for_confirmation() {
  read -p "Are you sure you want to uninstall CyberPanel? Type YES or NO: " response
  case $response in
    YES|yes|Yes)
      return 0
      ;;
    NO|no|No)
      log_message "You chose to abort the script. No changes done."
      exit 0
      ;;
    *)
      log_message "Invalid input. Please type YES or NO."
      ask_for_confirmation
      ;;
  esac
}

echo "This script is provided as-is, and you use it at your own risk. The authors and contributors disclaim any warranties, express or implied, and are not liable for any damages or losses resulting from the use of this script."

# Check if SELinux is disabled
if [ -x "$(command -v sestatus)" ]; then
  if ! sestatus | grep -q "disabled\|permissive"; then
    log_message "SELinux is enabled, disabling it..."
    run_command "sudo setenforce 0"
    run_command "sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config"
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
    elif grep -q "AlmaLinux release 8" "/etc/redhat-release" || grep -q "AlmaLinux release 9" "/etc/redhat-release"; then
      echo "cent8"
    elif grep -q "Rocky Linux release 8" "/etc/redhat-release" || grep -q "Rocky Linux 8" "/etc/redhat-release" || grep -q "rocky:8" "/etc/redhat-release"; then
      echo "cent8"
    elif grep -q "CloudLinux 8" "/etc/redhat-release" || grep -q "cloudlinux 8" "/etc/redhat-release"; then
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

# Uninstall OpenLiteSpeed
log_message "Uninstalling OpenLiteSpeed..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="sudo service lsws stop && yum remove openlitespeed -y && sudo /usr/local/lsws/admin/misc/rc-uninst.sh"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="sudo service lsws stop && dnf remove openlitespeed -y && sudo /usr/local/lsws/admin/misc/rc-uninst.sh"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="sudo service lsws stop && DEBIAN_FRONTEND=noninteractive apt purge openlitespeed -y && sudo /usr/local/lsws/admin/misc/rc-uninst.sh"
fi
run_command "$command"

log_message "Cleaning up OpenLiteSpeed..."
if [ -d "/usr/local/lsws" ]; then
  command="sudo rm -rf /usr/local/lsws"
  run_command "$command"
fi

# Uninstall PowerDNS
log_message "Uninstalling PowerDNS..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="sudo yum remove pdns pdns-backend-mysql -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="sudo dnf remove pdns pdns-backend-mysql -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="DEBIAN_FRONTEND=noninteractive apt purge pdns-server pdns-backend-mysql -y"
fi
run_command "$command"

run_command "sudo systemctl disable pdns 2>/dev/null || true"
run_command "sudo systemctl stop pdns 2>/dev/null || true"
run_command "sudo update-rc.d pdns remove 2>/dev/null || true"

# Remove PowerDNS configuration files
if [ -d "/etc/powerdns" ] || [ -d "/etc/pdns" ]; then
  run_command "sudo rm -rf /etc/powerdns /etc/pdns"
fi

# Restore original resolv.conf if it was renamed
if [ -f "/etc/resolved.conf" ]; then
  run_command "sudo mv /etc/resolved.conf /etc/resolv.conf"
fi

# Enable and start systemd-resolved if it was stopped
run_command "sudo systemctl enable systemd-resolved.service 2>/dev/null || true"
run_command "sudo systemctl start systemd-resolved.service 2>/dev/null || true"

# Uninstall Docker
log_message "Uninstalling Docker..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="service docker stop || true && yum remove docker-ce docker-ce-cli containerd.io docker-compose-plugin -y"
  run_command "$command"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="systemctl stop docker || true && dnf remove docker-ce docker-ce-cli containerd.io docker-compose-plugin -y"
  run_command "$command"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="systemctl stop docker || true && apt remove docker-ce docker-ce-cli containerd.io -y"
  run_command "$command"
fi
run_command "$command"

# Uninstall Pure-FTPd
log_message "Uninstalling Pure-FTPd..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="yum remove pure-ftpd -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="dnf remove pure-ftpd -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="DEBIAN_FRONTEND=noninteractive apt purge pure-ftpd-mysql -y"
fi
run_command "$command"

# Disable and stop the Pure-FTPD service
log_message "Disabling and Stopping Pure-FTPD service..."
if [ -f "/lib/systemd/system/pure-ftpd.service" ] || [ -f "/etc/init.d/pure-ftpd" ]; then
  run_command "sudo systemctl disable pure-ftpd 2>/dev/null || true"
  run_command "sudo systemctl stop pure-ftpd 2>/dev/null || true"
  run_command "sudo update-rc.d pure-ftpd remove 2>/dev/null || true"
fi

# Remove FTP user and group
log_message "Removing Pure-FTPD user and group..."
run_command "sudo userdel -f ftpuser 2>/dev/null || true"
run_command "sudo groupdel ftpgroup 2>/dev/null || true"

# Uninstall MariaDB
log_message "Uninstalling MariaDB..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="yum remove --remove-leaves mariadb-server mariadb -y && rm /etc/yum.repos.d/mariadb.repo"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="dnf remove mariadb-server mariadb-client -y && dnf module reset mariadb -y && dnf module disable mariadb -y && rm /etc/yum.repos.d/mariadb.repo"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="DEBIAN_FRONTEND=noninteractive apt remove mariadb-server mariadb-client -y && rm /etc/apt/sources.list.d/mariadb.sources"
fi
run_command "$command"

# Uninstall Redis
log_message "Uninstalling Redis..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="systemctl disable redis && yum remove --remove-leaves redis -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="service redis stop && dnf remove redis -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="systemctl disable redis && DEBIAN_FRONTEND=noninteractive apt purge redis-server -y"
fi
run_command "$command"

run_command "sudo rm -rf /usr/local/lsws"

# Uninstall Postfix
log_message "Uninstalling Postfix..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="yum remove --remove-leaves postfix -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="dnf remove postfix -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="DEBIAN_FRONTEND=noninteractive apt purge postfix -y"
fi
run_command "$command"

# Uninstall Dovecot
log_message "Uninstalling Dovecot..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="yum remove dovecot dovecot-mysql dovecot-pgsql dovecot-lmtpd dovecot-pigeonhole -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="dnf remove postfix -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="DEBIAN_FRONTEND=noninteractive apt remove dovecot-core dovecot-imapd dovecot-pop3d -y"
fi
run_command "$command"

# Uninstall LiteSpeed Memcached
log_message "Uninstalling LiteSpeed Memcached..."

if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  # Check if lsmcd service exists
  if systemctl list-units --type=service | grep -q "lsmcd.service"; then
    # Stop and disable the lsmcd service
    run_command "systemctl stop lsmcd"
    run_command "systemctl disable lsmcd"
    run_command "rm /etc/systemd/system/lsmcd.service"
    run_command "systemctl daemon-reload"
  fi

  # Check if lsmcd packages are installed
  if yum list installed | grep -q "autoconf\|automake\|zlib-devel\|openssl-devel\|expat-devel\|pcre-devel\|libmemcached-devel\|cyrus-sasl"; then
    # Uninstall packages installed using yum
    run_command "yum remove autoconf automake zlib-devel openssl-devel expat-devel pcre-devel libmemcached-devel cyrus-sasl* -y"
  fi

  # Check if compiled lsmcd software exists
  if [ -d /usr/local/lsmcd ] || [ -f /usr/local/bin/lsmcd ] || [ -d /usr/local/lib/lsmcd ]; then
    # Remove the compiled lsmcd software
    run_command "rm -rf /usr/local/lsmcd"
    run_command "rm -rf /usr/local/bin/lsmcd"
    run_command "rm -rf /usr/local/lib/lsmcd"
  fi

  # Check if source directory exists
  Current_Dir=$(pwd)
  if [ -d "$Current_Dir/lsmcd-master" ]; then
    # Remove the source directory
    run_command "rm -rf $Current_Dir/lsmcd-master"
  fi

  # Clean up any remaining files
  if [ -f lsmcd-master.zip ]; then
    run_command "rm lsmcd-master.zip"
  fi

elif [ "$DISTRO" = "ubuntu" ]; then
  # Check if lsmcd service exists
  if systemctl list-units --type=service | grep -q "lsmcd.service"; then
    # Stop and disable the lsmcd service
    run_command "systemctl stop lsmcd"
    run_command "systemctl disable lsmcd"
    run_command "rm /etc/systemd/system/lsmcd.service"
    run_command "systemctl daemon-reload"
  fi

  # Check if lsmcd packages are installed
  if dpkg -l | grep -q "build-essential\|zlib1g-dev\|libexpat1-dev\|openssl\|libssl-dev\|libsasl2-dev\|libpcre3-dev\|git"; then
    # Uninstall packages installed using apt
    run_command "DEBIAN_FRONTEND=noninteractive apt purge build-essential zlib1g-dev libexpat1-dev openssl libssl-dev libsasl2-dev libpcre3-dev git -y"
    run_command "DEBIAN_FRONTEND=noninteractive apt autoremove -y"
  fi

  # Check if compiled lsmcd software exists
  if [ -d /usr/local/lsmcd ] || [ -f /usr/local/bin/lsmcd ] || [ -d /usr/local/lib/lsmcd ]; then
    # Remove the compiled lsmcd software
    run_command "rm -rf /usr/local/lsmcd"
    run_command "rm -rf /usr/local/bin/lsmcd"
    run_command "rm -rf /usr/local/lib/lsmcd"
  fi
fi

# Uninstall Php
log_message "Uninstalling Php..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="yum remove lsphp71* lsphp72* lsphp73* lsphp74* lsphp80* lsphp81* lsphp82* lsphp83* -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="dnf remove lsphp71* lsphp72* lsphp73* lsphp74* lsphp80* lsphp81* lsphp82* lsphp83* -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="DEBIAN_FRONTEND=noninteractive apt purge lsphp7* lsphp80* lsphp81* lsphp82* lsphp83* -y"
fi
run_command "$command"

# Uninstall CrowdSec
log_message "Uninstalling CrowdSec..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="service crowdsec stop && yum remove crowdsec -y && rm -rf /etc/crowdsec/ && rm -rf /var/lib/crowdsec/ && rm -rf /var/log/crowdsec/"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="service crowdsec stop && dnf remove crowdsec -y && rm -rf /etc/crowdsec/ && rm -rf /var/lib/crowdsec/ && rm -rf /var/log/crowdsec/"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="systemctl stop crowdsec && DEBIAN_FRONTEND=noninteractive apt remove crowdsec -y && rm -rf /etc/crowdsec/ && rm -rf /var/lib/crowdsec/ && rm -rf /var/log/crowdsec/ && rm -f /etc/systemd/system/crowdsec-*"
fi
run_command "$command"

# Uninstall Rclone
log_message "Uninstalling Rclone..."
command="rm /usr/bin/rclone && rm /usr/local/share/man/man1/rclone.1"
run_command "$command"

# Uninstall Zip and Unzip
log_message "Uninstalling zip and unzip..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="yum remove zip unzip -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="dnf remove zip unzip -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="DEBIAN_FRONTEND=noninteractive apt purge zip unzip -y"
fi
run_command "$command"

# Clean up files and directories
log_message "Cleaning up files and directories..."
command="rm -rf /usr/local/CyberPanel"
run_command "$command"

# Clear all log files in /var/log/ except /var/log/uninstallLogs.txt
log_message "Clearing log files in /var/log/ except uninstallLogs.txt..."
command="find /var/log/ -type f ! -name 'uninstallLogs.txt' -delete"
run_command "$command"

# Remove users and groups
log_message "Removing users and groups..."
run_command "userdel cyberpanel"
run_command "groupdel docker"
run_command "userdel docker"

# Uninstall quota
log_message "Uninstalling quota..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  run_command "yum remove quota -y"
  # Revert fstab changes
  fstab_path="/etc/fstab"
  backup_path="$fstab_path.bak"
  if [ -f "$backup_path" ]; then
    mv "$backup_path" "$fstab_path"
  fi
  run_command "mount -o remount /"
elif [ "$DISTRO" = "ubuntu" ]; then
  run_command "DEBIAN_FRONTEND=noninteractive apt remove quota -y"
  run_command "apt autoremove -y"
  # Revert fstab changes
  fstab_path="/etc/fstab"
  backup_path="$fstab_path.bak"
  if [ -f "$backup_path" ]; then
    mv "$backup_path" "$fstab_path"
  fi
  run_command "mount -o remount /"
  run_command "quotacheck -ugm /"
  run_command "quotaoff -v /"
fi

# Remove temporary disk setup (if any)
log_message "Removing temporary disk setup (if any)..."
if [ -f "/usr/.tempdisk" ]; then
  run_command "umount /tmp"
  run_command "rm -f /usr/.tempdisk"
  run_command "rm -rf /usr/.tmpbak"
  # Revert fstab changes
  fstab_path="/etc/fstab"
  backup_path="$fstab_path.bak"
  if [ -f "$backup_path" ]; then
    mv "$backup_path" "$fstab_path"
  fi
  run_command "mount -o remount /"
fi

# Remove installed packages
log_message "Uninstalling installed packages..."
if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
  command="sudo yum autoremove -y"
elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
  command="sudo dnf autoremove -y"
elif [ "$DISTRO" = "ubuntu" ]; then
  command="sudo apt autoremove -y"
fi
run_command "$command"

# Uninstall Sudo (Note: This is generally not recommended as it can break system functionality)
# log_message "Uninstalling sudo..."
# if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "cent7" ]; then
#   command="yum remove sudo -y"
# elif [ "$DISTRO" = "cent8" ] || [ "$DISTRO" = "openeuler" ]; then
#   command="sudo dnf remove sudo -y"
# elif [ "$DISTRO" = "ubuntu" ]; then
#   command="apt remove sudo -y"
# fi
# run_command "$command"

log_message "Uninstallation completed successfully."

echo "=============================================================================================================="
echo "Uninstallation completed successfully." 
echo "=============================================================================================================="
