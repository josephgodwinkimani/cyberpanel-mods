#!/usr/bin/env bash

# drop into /usr/local/

# RUn rclone copy all incremental backups at (/home/backups) to remote cloud e.g. gdrive, mega etc.
# This file is dropped in by https://github.com/josephgodwinkimani/cyberpanel at /usr/local/CyberCP

TIMESTAMP=$(date +"%Y-%m-%d")

MYSQL=/usr/bin/mysql

MYSQLDUMP=/usr/bin/mysqldump

# edit me
MYSQL_USER=root

# edit me
MYSQL_PASSWORD=""

# edit me e.g. /home/backup/sql
BACKUP_DIR=""

$MYSQLDUMP --user=$MYSQL_USER -p$MYSQL_PASSWORD --all-databases | gzip > "$BACKUP_DIR/backup-$TIMESTAMP.sql.gz"

# If you are only copying a small number of files (or are filtering most of the files) and/or have a large number of files on the destination then 
# --no-traverse will stop rclone listing the destination and save time.

rclone copy --no-traverse "$BACKUP_DIR/backup-$TIMESTAMP.sql.gz" remote:backup/sql
