#!/usr/bin/env bash

TIMESTAMP=$(date +"%Y-%m-%d")

MYSQL=/usr/bin/mysql

MYSQLDUMP=/usr/bin/mysqldump

echo "RCLONE backup (and encrypt) files to cloud storage"

echo "What is your mysql user with all privileges? (e.g. root)"
read MYSQL_USER

echo "What is your $MYSQL_USER password? (e.g. root password found in /usr/local/CyberCP/CyberCP/settings.py)"
read MYSQL_PASSWORD

echo "Where do you want to dump your backup on CyberPanel? (e.g. /home/mydomain.com/public_html/backup)"
read BACKUP_DIR

echo "Where do you want to dump your backup on Remote? (e.g. backup/dir = remote:backup/dir {remote = MEGA/GDRIVE, backup/dir = directory}) "
read REMOTE_DIR

mkdir -p "$BACKUP_DIR"

$MYSQLDUMP --user=$MYSQL_USER -p$MYSQL_PASSWORD --all-databases | gzip > "$BACKUP_DIR/backup-$TIMESTAMP.sql.gz"

# If you are only copying a small number of files (or are filtering most of the files) and/or have a large number of files on the destination then 
# --no-traverse will stop rclone listing the destination and save time.

rclone copy --progress "$BACKUP_DIR/backup-$TIMESTAMP.sql.gz" remote:$REMOTE_DIR

echo ""

echo "Local backup at $BACKUP_DIR/backup-$TIMESTAMP.sql.gz, Remote backup at $REMOTE_DIR/backup-$TIMESTAMP.sql.gz"
