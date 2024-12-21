#!/usr/bin/env bash

TIMESTAMP=$(date +"%Y-%m-%d")

MYSQL=/usr/bin/mysql

MYSQLDUMP=/usr/bin/mysqldump

echo "LOCAL Backup"

echo "What is your mysql user with all privileges? (e.g. root)"
read MYSQL_USER

echo "What is your $MYSQL_USER password? (e.g. root password found in /usr/local/CyberCP/CyberCP/settings.py)"
read MYSQL_PASSWORD

echo "Where do you want to dump your backup on CyberPanel? (e.g. /home/mydomain.com/public_html/backup)"
read BACKUP_DIR

mkdir -p "$BACKUP_DIR"

$MYSQLDUMP --user=$MYSQL_USER -p$MYSQL_PASSWORD --all-databases | gzip > "$BACKUP_DIR/backup-$TIMESTAMP.sql.gz"

echo ""

echo "Local backup at $BACKUP_DIR/backup-$TIMESTAMP.sql.gz"
