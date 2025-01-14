#!/bin/bash

# This script allows you to check if essential services are running, if any of the services is not running it attempts to start it.
# Add to crontab - 0 0 * * * /bin/bash /root/cyberpanel-mods/check_services.sh >/dev/null 2>&1

if [ ${EUID} -ne 0 ]; then
    echo "Please run as root or sudo user"
    exit 1
fi

# Set the log file path
LOG_FILE="/var/log/cyberp-services-check.log"

# Function to log messages
log_message() {
    local timestamp="$(date +'%m.%d.%Y_%H-%M-%S')"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# List of services to check, add here
services=(
    "pdns"
    "lshttpd"
    "lscpd"
    "opendkim"
    "mariadb.service"
    "fail2ban.service"
    "lsmcd"
    "crowdsec"
    "pure-ftpd"
    "redis"
    "fail2ban"
    "crond"
    "sshd"
    "rsyslog"
)

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "$service is running."
        log_message "$service is running."
    else
        echo "$service is not running. Starting $service..."
        log_message "$service is not running. Attempting to start..."

        start_output=$(systemctl start "$service" 2>&1)
        
        if systemctl is-active --quiet "$service"; then
            echo "$service has been started successfully."
            log_message "$service has been started successfully."
        else
            echo "Failed to start $service. Reason: $start_output"
            log_message "Failed to start $service. Reason: $start_output"
        fi
    fi
done
