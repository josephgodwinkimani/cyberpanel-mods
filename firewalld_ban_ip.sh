#!/bin/bash

# This script allows you to block a specified IP address using `firewalld`. 
# It prompts the user for the rule family (either `ipv4` or `ipv6`) and the IP address to be blocked. 

if [ ${EUID} -ne 0 ]; then
    echo "Please run as root or sudo user"
    exit 1
fi

# Set the log file path
LOG_FILE="/var/log/firewalld-bans.txt"

# Function to log messages
log_message() {
    local timestamp="$(date +'%m.%d.%Y_%H-%M-%S')"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Prompt for rule family
read -p "Enter the rule family (ipv4 or ipv6): " RULE_FAMILY

# Validate input for rule family
if [[ "$RULE_FAMILY" != "ipv4" && "$RULE_FAMILY" != "ipv6" ]]; then
    echo "Invalid rule family. Please enter 'ipv4' or 'ipv6'."
    exit 1
fi

# Prompt for IP address to block
read -p "Enter the IP address to block: " IP_TO_BLOCK

# Validate input for IP address format
if ! [[ "$IP_TO_BLOCK" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ "$RULE_FAMILY" == "ipv4" ]]; then
    echo "Invalid IPv4 address format."
    exit 1
elif ! [[ "$IP_TO_BLOCK" =~ ^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|::([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4}$ ]] && [[ "$RULE_FAMILY" == "ipv6" ]]; then
    echo "Invalid IPv6 address format."
    exit 1
fi

# Add the IP address to firewalld
if firewall-cmd --permanent --add-rich-rule="rule family='$RULE_FAMILY' source address='$IP_TO_BLOCK' reject"; then
    log_message "Successfully added rule to block IP: $IP_TO_BLOCK with family: $RULE_FAMILY"
else
    log_message "Failed to add rule to block IP: $IP_TO_BLOCK with family: $RULE_FAMILY"
    exit 1
fi

# Reload firewalld to apply changes
if firewall-cmd --reload; then
    log_message "Firewalld reloaded successfully."
else
    log_message "Failed to reload firewalld."
    exit 1
fi

# Verify that the rule has been added
if firewall-cmd --list-rich-rules | grep -q "$IP_TO_BLOCK"; then
    log_message "IP $IP_TO_BLOCK is successfully blocked."
else
    log_message "IP $IP_TO_BLOCK was not found in the rich rules."
fi

echo "================================================================================================================"
echo "Successfully banned $IP_TO_BLOCK with family $RULE_FAMILY. Check $LOG_FILE for details."
