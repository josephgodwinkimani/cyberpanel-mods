#!/bin/bash

# Trap to handle exit status
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

# Enable strict mode
set -e

# Function to log information
log_info() {
    printf "\n\e[0;35m $1\e[0m\n\n"
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root..."
    exit 1
fi

# Output file name
OUTPUT_FILE="package_sources.txt"

# Function to detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Get the distribution name
distro=$(detect_distro)

# Function to get the source of an installed package
get_package_source() {
    local package_name="$1"
    local source=""
    local version=""

    # Get the version of the installed package based on the distribution
    if [[ "$distro" == "ubuntu" || "$distro" == "debian" ]]; then
        version=$(dpkg -l | grep "^ii  $package_name" | awk '{print $3}')
        if [ -n "$version" ]; then
            source=$(apt-cache policy "$package_name" | grep " 500 http" | awk '{print $2}')
            if [ -z "$source" ]; then
                source=$(apt-cache show "$package_name" | grep "Source:" | awk '{print $2}')
            fi
        fi
    elif [[ "$distro" == "centos" || "$distro" == "almalinux" || "$distro" == "rocky" ]]; then
        version=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}\n' "$package_name")
        if [ $? -eq 0 ]; then
            source=$(yum info "$package_name" | grep "From repo:" | awk '{print $3}')
        fi
    fi

    echo "$package_name: $source"
}

# List all installed packages and get their sources based on the distribution
if [[ "$distro" == "ubuntu" || "$distro" == "debian" ]]; then
    installed_packages=$(dpkg -l | grep "^ii" | awk '{print $2}')
elif [[ "$distro" == "centos" || "$distro" == "almalinux" || "$distro" == "rocky" ]]; then
    installed_packages=$(rpm -qa)
else
    log_info "Unsupported distribution: $distro"
    exit 1
fi

# Create the output file and write the header
> "$OUTPUT_FILE" 2>/dev/null || {
    log_info "Failed to create $OUTPUT_FILE"
    exit 1
}

echo "Installed Packages and Their Sources:" >> "$OUTPUT_FILE"

log_info "Listing installed packages and their sources..."

for package in $installed_packages; do
    get_package_source "$package" >> "$OUTPUT_FILE" || {
        echo "Failed to gather source for package $package."
        log_info "Failed to gather source for package $package."
    }
done

log_info "Installed packages and their sources saved to $OUTPUT_FILE"

echo "==========================================================="
echo "Process Complete. Check $OUTPUT_FILE"
echo "==========================================================="
