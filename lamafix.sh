#!/bin/bash
# Thanks to https://raw.githubusercontent.com/shbs9/CPupgradebash/refs/heads/main/lamafix.sh this has been improved.

# Define log file
LOG_FILE="/var/log/lamafix.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to execute commands with error handling
execute_command() {
    "$@" || { log_message "Error: Command '$*' failed. Exiting script."; exit 1; }
}

# Start logging
log_message "Script execution initiated."

# Check for AlmaLinux distribution
log_message "Verifying the operating system distribution..."
if ! grep -q 'ID="almalinux"' /etc/os-release; then
    log_message "This script is designed exclusively for AlmaLinux. Terminating execution."
    exit 1
fi
log_message "Operating system verified: AlmaLinux detected."

# Inform user about the specific error and prompt for confirmation
log_message "This script addresses the issue: 'Command \"python setup.py egg_info\" failed with error code 1 in /tmp/pip-build-pjuquie_/pynacl/' encountered upgrading CyberPanel installations on AlmaLinux."
read -p "Do you wish to continue? (yes/YES or no/NO): " user_response

if [[ ! "$user_response" =~ ^(yes|YES)$ ]]; then
    log_message "You opted not to continue. No changes were made."
    exit 0
fi

log_message "User chose to continue with the installation process."

# Securely upgrade pip, setuptools, and wheel with additional information
log_message "Initiating upgrade for pip, setuptools, and wheel..."
execute_command pip install --upgrade pip setuptools wheel
log_message "Successfully upgraded pip, setuptools, and wheel."

# Display OS information securely
log_message "Retrieving operating system information..."
if [ -f /etc/os-release ]; then
    cat /etc/os-release | tee -a "$LOG_FILE"
else
    log_message "Warning: /etc/os-release file not found. Unable to retrieve OS information."
fi

# Install Development Tools group securely with error handling
log_message "Commencing installation of Development Tools..."
execute_command sudo dnf groupinstall "Development Tools" -y
log_message "Development Tools installation completed successfully."

# Install necessary libraries securely with error handling
log_message "Installing required libraries: python3-devel, libffi-devel, and openssl-devel..."
execute_command sudo dnf install python3-devel libffi-devel openssl-devel -y
log_message "Required libraries installed successfully."

# Install pynacl with pip securely, including extra information about installation options
log_message "Installing the pynacl package with additional options..."
execute_command pip install pynacl --no-cache-dir --verbose
log_message "Pynacl package installed successfully."

# Re-upgrade pip as the last step if required
log_message "Performing final upgrade of pip..."
execute_command pip install --upgrade pip --no-cache-dir --verbose
log_message "Final pip upgrade completed successfully."

log_message "Python package installation fixed. Kindly check $LOG_FILE"
