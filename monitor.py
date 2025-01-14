# This script monitors in real-time for both Ubuntu, CentOs, Almalinux:

# 1. Your server CPU , Memory, Disk Usage, Process Count
# 2. Service health checks for PowerDNS Authoritative Server, LiteSpeed/OpenLiteSpeed HTTP Server, MariaDB database server, Command Scheduler, Pure-FTPd FTP server, Fail2Ban Service, DomainKeys Identified Mail (DKIM) Milter, LiteSpeed LSMCD Daemon and Redis
# 3. Monitors for failed SSH login attempts
# 4. Analyze the last 1000 lines from /usr/local/lsws/logs/error.log, /usr/local/lsws/logs/stderr.log, /usr/local/lsws/logs/access.log for high traffic ips
# 5. Send important notifications to Email via SMTP or Discord via webhook

# How to add it into cron ? Just copy and paste => * * * * * /usr/bin/python3 /root/monitor.py >> /var/log/cyberpanel_monitoring/cron.log 2>&1

# Inspired by https://forum.hhf.technology/t/comprehensive-guide-to-cloudpanel-server-monitoring-implementation-and-setup-ubuntu-2024/464/1


# This script monitors in real-time for both Ubuntu, CentOs, Almalinux:

# 1. Your server CPU , Memory, Disk Usage, Process Count
# 2. Service health checks for PowerDNS Authoritative Server, LiteSpeed/OpenLiteSpeed HTTP Server, MariaDB database server, Command Scheduler, Pure-FTPd FTP server, Fail2Ban Service, DomainKeys Identified Mail (DKIM) Milter, LiteSpeed LSMCD Daemon and Redis
# 3. Monitors for failed SSH login attempts
# 4. Analyze the last 1000 lines from the specified access log and error log file of respective websites
# 5. Send important notifications to Email via SMTP or Discord via webhook

# How to add it into cron ? Just copy and paste => * * * * * /usr/bin/python3 /root/monitor.py >> /var/log/cyberpanel_monitoring/cron.log 2>&1

# Inspired by https://forum.hhf.technology/t/comprehensive-guide-to-cloudpanel-server-monitoring-implementation-and-setup-ubuntu-2024/464/1


import os
import smtplib
import subprocess
import time
import json
import requests
from datetime import datetime

# Configuration
ENABLE_EMAIL = False
ENABLE_DISCORD = True
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/"
GMAIL_USER = "your-gmail@gmail.com"
GMAIL_APP_PASSWORD = "your-app-password"
EMAIL_TO = "your-org-email@domain.com"

CPU_THRESHOLD = 80
MEMORY_THRESHOLD = 90
PROCESS_THRESHOLD = 500
DISK_THRESHOLD = 90
CHECK_INTERVAL = 300

OUTPUT_DIR = "/var/log/cyberpanel_monitoring"
ALERT_LOG = os.path.join(OUTPUT_DIR, "alerts.log")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def log(message, color=""):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted_message = f"{color}[{timestamp}] {message}\033[0m"
    print(formatted_message)
    with open(os.path.join(OUTPUT_DIR, "monitoring.log"), "a") as f:
        f.write(formatted_message + "\n")

def validate_config():
    has_error = False

    if ENABLE_EMAIL:
        if not GMAIL_USER or GMAIL_USER == "your-gmail@gmail.com":
            log("Error: GMAIL_USER not configured", "\033[0;31m")
            has_error = True
        if not GMAIL_APP_PASSWORD or GMAIL_APP_PASSWORD == "your-app-password":
            log("Error: GMAIL_APP_PASSWORD not configured", "\033[0;31m")
            has_error = True
        if not EMAIL_TO or EMAIL_TO == "your-org-email@domain.com":
            log("Error: EMAIL_TO not configured", "\033[0;31m")
            has_error = True

    if ENABLE_DISCORD:
        if not DISCORD_WEBHOOK_URL or DISCORD_WEBHOOK_URL == "your-discord-webhook-url":
            log("Error: DISCORD_WEBHOOK_URL not configured", "\033[0;31m")
            has_error = True

    if has_error:
        log("Configuration validation failed. Please check settings.", "\033[0;31m")
        exit(1)

def send_discord_alert(title, message, priority):
    color = 16711680 if priority == "high" else 15844367

    json_data = {
        "embeds": [
            {
                "title": title,
                "description": message,
                "color": color,
                "footer": {"text": f"CyberPanel Monitoring - {os.uname().nodename}"},
                "timestamp": datetime.utcnow().isoformat() + "Z",
            }
        ]
    }

    response = requests.post(DISCORD_WEBHOOK_URL, json=json_data)
    if response.status_code != 204:
        log(f"Discord API response: {response.text}", "\033[0;31m")

def send_gmail(subject, message, priority):
    email_content = f"""From: {GMAIL_USER}
To: {EMAIL_TO}
Subject: {'[URGENT] ' if priority == 'high' else ''}{subject}
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"

{message}
"""

    with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
        server.login(GMAIL_USER, GMAIL_APP_PASSWORD)
        server.sendmail(GMAIL_USER, EMAIL_TO, email_content)

def send_alert(subject, message, priority):
    formatted_message = f"""
Server: {os.uname().nodename}
Time: {datetime.now()}

{message}

This is an automated alert from CyberPanel Monitoring System."""

    if ENABLE_EMAIL:
        send_gmail(subject, formatted_message, priority)
        log(f"Email alert sent: {subject}", "\033[1;33m")

    if ENABLE_DISCORD:
        send_discord_alert(subject, formatted_message, priority)
        log(f"Discord alert sent: {subject}", "\033[1;33m")

    with open(ALERT_LOG, "a") as f:
        f.write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {subject}\n")

def is_log_empty(log_path):
    return os.path.isfile(log_path) and os.stat(log_path).st_size == 0

def check_system_resources():
    log("Checking system resources...", "\033[0;34m")

    cpu_usage = float(
        subprocess.check_output(
            "top -bn1 | grep 'Cpu(s)' | awk '{print $2}'", shell=True
        )
    )
    if cpu_usage > CPU_THRESHOLD:
        top_processes = subprocess.check_output(
            "ps aux --sort=-%cpu | head -n 6", shell=True
        ).decode()
        send_alert(
            "High CPU Usage Alert",
            f"CPU Usage: {cpu_usage}%\n\nTop Processes:\n{top_processes}",
            "high",
        )

    memory_usage = float(
        subprocess.check_output(
            "free | grep Mem | awk '{print ($3/$2 * 100)}'", shell=True
        )
    )
    if memory_usage > MEMORY_THRESHOLD:
        memory_processes = subprocess.check_output(
            "ps aux --sort=-%mem | head -n 6", shell=True
        ).decode()
        send_alert(
            "High Memory Usage Alert",
            f"Memory Usage: {memory_usage}%\n\nTop Memory Processes:\n{memory_processes}",
            "high",
        )

    process_count = int(subprocess.check_output("ps aux | wc -l", shell=True))
    if process_count > PROCESS_THRESHOLD:
        send_alert(
            "High Process Count Alert",
            f"Process Count: {process_count}\n\nProcess List:\n{top_processes}",
            "high",
        )

    disk_usage = int(
        subprocess.check_output(
            "df -h | awk '$NF==\"/\" {print $5}' | cut -d% -f1", shell=True
        )
    )
    if disk_usage > DISK_THRESHOLD:
        disk_info = subprocess.check_output("df -h", shell=True).decode()
        send_alert(
            "High Disk Usage Alert",
            f"Disk Usage: {disk_usage}%\n\nDisk Information:\n{disk_info}",
            "high",
        )

def check_services():
    log("Checking critical services...", "\033[0;34m")

    basic_services = [
        "pdns",
        "lshttpd",
        "lscpd",
        "opendkim",
        "mariadb.service",
        "fail2ban.service",
        "lsmcd",
        "pure-ftpd",
        "redis",
        "fail2ban",
        "crond",
        "sshd",
        "rsyslog",
        # "crowdsec"
    ]

    for service in basic_services:
        status_command = ["systemctl", "is-active", "--quiet", service]

        try:
            subprocess.run(status_command, check=True)
        except subprocess.CalledProcessError:
            send_alert(
                "Service Down Alert!", f"Service {service} is not running!", "high"
            )

def check_security():
    log("Checking security...", "\033[0;34m")

    failed_ssh_attempts_command = (
        "grep 'Failed password' /var/log/auth.log 2>/dev/null || "
        "grep 'Failed password' /var/log/secure"
    )

    failed_ssh_attempts = (
        subprocess.check_output(failed_ssh_attempts_command, shell=True)
        .decode()
        .strip()
    )

    if failed_ssh_attempts:
        send_alert(
            "Security Alert - Failed SSH Attempts",
            f"Recent failed SSH attempts:\n{failed_ssh_attempts}",
            "normal",
        )

    # Check for recently modified files in /etc, /usr/bin, /usr/sbin.
    modified_files_command = (
        "find /etc /usr/bin /usr/sbin -mmin -60 -type f 2>/dev/null"
    )
    modified_files = (
        subprocess.check_output(modified_files_command, shell=True).decode().strip()
    )

    # Only send an alert if there are modified files.
    if modified_files:
        send_alert(
            "Security Alert - Modified System Files",
            f"Recently modified system files:\n{modified_files}",
            "high",
        )

def analyze_logs():
    log("Analyzing LiteSpeed logs...", "\033[0;34m")

    logs_to_check = [
        "/usr/local/lsws/logs/error.log",
        "/usr/local/lsws/logs/access.log",
        "/usr/local/lsws/logs/stderr.log",
    ]

    for log_path in logs_to_check:
        # Check if the log file exists and is not empty
        if os.path.isfile(log_path):
            if is_log_empty(log_path):
                continue  # Skip empty logs

            # Read the last 1000 lines of the log file into a variable
            with open(log_path) as file:
                log_content_lines = file.readlines()[-1000:]
                log_content = ''.join(log_content_lines)

                # Check for errors in access and error logs specifically
                if ("error" in log_path or "stderr" in log_path) and log_content.strip():
                    send_alert(
                        f"Error Log Analysis for {log_path}!",
                        f"\nRecent errors:\n{log_content}\n",
                        "normal",
                    )
                elif ("access" in log_path):
                    # Analyze access logs for high traffic or errors (if applicable)
                    ip_counts = {}
                    for line in log_content.splitlines():
                        ip_address = line.split()[0]
                        ip_counts[ip_address] = ip_counts.get(ip_address, 0) + 1
                    
                    high_traffic_ips_sorted = sorted(ip_counts.items(), key=lambda x: x[1], reverse=True)[:5]
                    high_traffic_ips_reported = '\n'.join([f"{ip}: {count}" for ip, count in high_traffic_ips_sorted])
                    
                    send_alert(
                        f"Access Log Analysis for {log_path}!",
                        f"\nHigh traffic IPs:\n{high_traffic_ips_reported}\n",
                        "normal",
                    )

def main():
    log("Starting CyberPanel monitoring system...", "\033[0;32m")

    validate_config()

    while True:
        check_system_resources()
        check_services()
        check_security()
        analyze_logs()

        log(f"Sleeeping for {CHECK_INTERVAL} seconds...", "\033[0;34m")
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
