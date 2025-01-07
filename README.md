Useful bash scripts and files for [cyberpanel](https://github.com/usmannasir/cyberpanel/tree/stable) and my fork - [cyberpanel](https://github.com/josephgodwinkimani/cyberpanel)

# How to use any script

> change `script.sh` to whichever script you want to use here

```
sh <(curl https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/script.sh || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/script.sh)
```

OR for Non-root user

```bash
sudo su - -c "sh <(curl https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/script.sh || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/script.sh)"
```

OR for php scripts

```
php <(curl -s https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/script.php || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/script.php)
```

Example logs from uninstalling CyberPanel

```
[01.07.2025_18-27-06] Uninstalling OpenLiteSpeed...
[01.07.2025_18-27-20] [ERROR] Failed to run: DEBIAN_FRONTEND=noninteractive apt purge openlitespeed -y && service lsws stop && /usr/local/lsws/admin/misc/rc-uninst.sh
[01.07.2025_18-28-48] Uninstalling OpenLiteSpeed...
[01.07.2025_18-28-53] Successfully ran: service lsws stop && DEBIAN_FRONTEND=noninteractive apt purge openlitespeed -y
[01.07.2025_18-28-53] [WARNING] rc-uninst.sh not found; skipping this step.
[01.07.2025_18-28-53] Cleaning up OpenLiteSpeed...
[01.07.2025_18-28-53] Uninstalling PowerDNS...
[01.07.2025_18-28-55] Successfully ran: DEBIAN_FRONTEND=noninteractive apt purge pdns-server pdns-backend-mysql -y
[01.07.2025_18-28-55] [INFO] Uninstallation completed successfully.
[01.07.2025_18-30-55] Removing Gunicorn files...
[01.07.2025_18-30-55] Successfully ran: rm -f /etc/systemd/system/gunicorn.service
[01.07.2025_18-30-55] Successfully ran: rm -f /etc/systemd/system/gunicorn.socket
[01.07.2025_18-30-55] Successfully ran: rm -f /etc/tmpfiles.d/gunicorn.conf
[01.07.2025_18-30-55] Uninstalling OpenLiteSpeed...
[01.07.2025_18-30-57] Successfully ran: service lsws stop && DEBIAN_FRONTEND=noninteractive apt purge openlitespeed -y
[01.07.2025_18-30-57] Cleaning up OpenLiteSpeed directory...
[01.07.2025_18-30-57] Uninstalling PowerDNS...
[01.07.2025_18-30-57] Successfully ran: systemctl stop pdns.service
[01.07.2025_18-30-57] [ERROR] Failed to run: systemctl disable pdns.service
[01.07.2025_18-31-52] Removing Gunicorn files...
[01.07.2025_18-31-52] Successfully ran: rm -f /etc/systemd/system/gunicorn.service
[01.07.2025_18-31-52] Successfully ran: rm -f /etc/systemd/system/gunicorn.socket
[01.07.2025_18-31-52] Successfully ran: rm -f /etc/tmpfiles.d/gunicorn.conf
[01.07.2025_18-31-52] Uninstalling OpenLiteSpeed...
[01.07.2025_18-31-56] Successfully ran: service lsws stop && DEBIAN_FRONTEND=noninteractive apt purge openlitespeed -y
[01.07.2025_18-31-56] Cleaning up OpenLiteSpeed directory...
[01.07.2025_18-31-56] Uninstalling PowerDNS...
[01.07.2025_18-31-58] Successfully ran: DEBIAN_FRONTEND=noninteractive apt purge pdns-server pdns-backend-mysql -y
[01.07.2025_18-31-58] Successfully ran: systemctl enable systemd-resolved.service 2>/dev/null || true
[01.07.2025_18-31-58] Successfully ran: systemctl start systemd-resolved.service 2>/dev/null || true
[01.07.2025_18-31-58] Uninstalling Docker...
[01.07.2025_18-31-59] [WARNING] Failed to run: systemctl stop docker || true && apt remove docker-ce docker-ce-cli containerd.io -y
[01.07.2025_18-31-59] Uninstalling Pure-FTPd...
[01.07.2025_18-32-07] Successfully ran: DEBIAN_FRONTEND=noninteractive apt purge pure-ftpd-mysql -y
[01.07.2025_18-32-07] Removing Pure-FTPd user and group...
[01.07.2025_18-32-07] Successfully ran: userdel ftpuser 2>/dev/null || true
[01.07.2025_18-32-08] Successfully ran: groupdel ftpgroup 2>/dev/null || true
[01.07.2025_18-32-08] Uninstalling MariaDB...
[01.07.2025_18-32-16] [WARNING] Failed to run: DEBIAN_FRONTEND=noninteractive apt remove mariadb-server mariadb-client -y && rm /etc/apt/sources.list.d/mariadb.sources
[01.07.2025_18-32-16] Uninstalling Redis...
[01.07.2025_18-32-28] Successfully ran: systemctl disable redis && DEBIAN_FRONTEND=noninteractive apt purge redis-server -y
[01.07.2025_18-32-28] Uninstalling Postfix...
[01.07.2025_18-32-31] Successfully ran: DEBIAN_FRONTEND=noninteractive apt purge postfix -y
[01.07.2025_18-32-31] Uninstalling Dovecot...
[01.07.2025_18-32-34] Successfully ran: DEBIAN_FRONTEND=noninteractive apt remove dovecot-core dovecot-imapd dovecot-pop3d -y
[01.07.2025_18-32-34] Cleaning up files and directories...
[01.07.2025_18-32-40] Successfully ran: rm -rf /usr/local/CyberPanel
[01.07.2025_18-32-40] Clearing log files in /var/log/ except uninstallLogs.txt...
[01.07.2025_18-32-40] Successfully ran: find /var/log/ -type f ! -name 'uninstallLogs.txt' -delete
[01.07.2025_18-32-40] Removing users and groups...
[01.07.2025_18-32-40] Successfully ran: userdel cyberpanel 2>/dev/null || true
[01.07.2025_18-32-40] [INFO] Uninstallation completed successfully.
```
# Disclaimer

The information, software, and any other materials provided in this repository are made available "as is" and "as available" without any warranties of any kind, either express or implied. By using the contents of this repository, you acknowledge that you are doing so at your own risk.

You understand and agree that the authors, maintainers, and contributors of this repository are not liable for any direct, indirect, incidental, consequential, special, punitive, or exemplary damages or losses, including but not limited to:

- Any damages or losses arising from the use or inability to use the materials provided.
- Any errors or omissions in the materials.
- Any financial losses incurred by acting on the information provided.
- Any other damages or losses that may arise from the use of the materials.

By using the materials in this repository, you assume all risks associated with such use, including but not limited to the risk of errors, omissions, and inaccuracies. You release and hold harmless the authors, maintainers, and contributors of this repository from any and all claims, demands, and causes of action that may arise from your use of the materials.

By proceeding to use the materials in this repository, you acknowledge that you have read, understood, and agree to the terms of this disclaimer.
