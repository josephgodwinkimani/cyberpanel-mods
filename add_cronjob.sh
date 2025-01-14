#!/bin/bash

# This script allows you to add a python or php or bash script to crontab. 
# Borrowed from https://github.com/josephgodwinkimani/install-cloudpanel/blob/main/add_cronjob.sh

# Example prompting to add a cron job that runs every minute:

# Enter the full path of your script: /root/cyberpanel-mods/monitor.py
# Enter frequency (in minutes or seconds) or preset (once a day, week, or month): 1
# Enter day of the week (0-7): 0
# Enter day of the month (1-31): 1
# Enter month of the year (1-12): 1
# Enter the path of the output file (optional): 
# Cron job added successfully: * * * * * /usr/bin/python3 /root/cyberpanel-mods/monitor.py >/dev/null 2>&1

if [ ${EUID} -ne 0 ]; then
    echo "Please run as root or sudo user"
    exit 1
fi

# Display usage information if no arguments are provided
if [ $# -eq 0 ]; then
    usage
fi

# Display usage information
usage() {
    cat << EOF
Usage: $0
This script adds a cron job to the crontab.
You will be prompted for the following:
1. Command to run (Python, PHP, or Bash script e.g. /root/cyberpanel-mods/database_dump.php)
2. Frequency (in minutes or seconds) or choose preset (once a day, week, or month)
3. Day of the week (0-7, where 0 and 7 are Sunday)
4. Day of the month (1-31)
5. Month of the year (1-12)
6. Output file path (optional)
EOF
    exit 1
}

validate_input() {
    local input="$1"
    local type="$2"

    case "$type" in
        "command")
            if [[ ! -f "$input" ]]; then
                echo "Error: The command '$input' does not exist."
                exit 1
            fi
            ;;
        "frequency")
            if [[ "$input" == "once a day" ]]; then
                frequency="0 0 * * *"  # At midnight every day
            elif [[ "$input" == "once a week" ]]; then
                frequency="0 0 * * 0"  # At midnight every Sunday
            elif [[ "$input" == "once a month" ]]; then
                frequency="0 1 1 * *"  # At 1 AM on the first day of every month
            elif ! [[ "$input" =~ ^[0-9]+$ ]]; then
                echo "Error: Frequency must be a number or a preset (once a day, week, or month)."
                exit 1
            else
                frequency="$input"
            fi
            ;;
        "day_of_week")
            if ! [[ "$input" =~ ^[0-7]$ ]]; then
                echo "Error: Day of the week must be between 0 and 7."
                exit 1
            fi
            ;;
        "day_of_month")
            if ! [[ "$input" =~ ^(0?[1-9]|[12][0-9]|3[01])$ ]]; then
                echo "Error: Day of the month must be between 1 and 31."
                exit 1
            fi
            ;;
        "month")
            if ! [[ "$input" =~ ^(0?[1-9]|1[0-2])$ ]]; then
                echo "Error: Month must be between 1 and 12."
                exit 1
            fi
            ;;
    esac
}

read -p "Enter the full path of your script (Python, PHP, or Bash script e.g. /root/cyberpanel-mods/database_dump.php): " SCRIPT_PATH

case "$SCRIPT_PATH" in
    *.py) COMMAND="/usr/bin/python3 $SCRIPT_PATH";;
    *.php) COMMAND="/usr/bin/php $SCRIPT_PATH";;
    *.sh) COMMAND="/bin/bash $SCRIPT_PATH";;
    *) 
        echo "Unsupported script type. Please provide a .py, .php, or .sh file."
        exit 1;;
esac

validate_input "$SCRIPT_PATH" "command"

read -p "Enter frequency (in minutes or seconds) or preset (once a day, once a week, or once a month): " frequency_input

validate_input "$frequency_input" "frequency"

# If using preset frequencies, skip to output file prompt.
if [[ "$frequency_input" == "once a day" || "$frequency_input" == "once a week" || "$frequency_input" == "once a month" ]]; then 
    cron_job="$frequency $COMMAND"
else 
    if [[ "$frequency_input" =~ ^[0-9]+$ ]] && [[ "$frequency_input" -lt 60 ]]; then
        # Convert seconds to minutes for cron format.
        frequency="$((frequency_input / 60)) * * * *" 
    else 
        read -p "Enter day of the week (0-7): " day_of_week_input
        validate_input "$day_of_week_input" "day_of_week"

        read -p "Enter day of the month (1-31): " day_of_month_input
        validate_input "$day_of_month_input" "day_of_month"

        read -p "Enter month of the year (1-12): " month_input
        validate_input "$month_input" "month"
        
        cron_job="$frequency $month_input $day_of_month_input $day_of_week_input $COMMAND"
    fi 
fi

read -p "Enter the path of the output file (optional): " output_file

if [[ -z "$output_file" ]]; then 
    cron_job="$cron_job >/dev/null 2>&1"
else 
    cron_job="$cron_job >> $output_file 2>&1"
fi

(crontab -l; echo "$cron_job") | crontab -

echo "Cron job added successfully: $cron_job"
