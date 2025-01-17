#!/bin/bash

if [ ${EUID} -ne 0 ]; then
    echo "Please run as root or sudo user"
    exit 1
fi

# Log file path
logFile="/var/log/delete_yesterday_backups.log"

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$logFile"
}

# Get yesterday's date in required formats
yesterdayDate=$(date -d "yesterday" +"%m.%d.%Y")
yesterdayBackupFile=$(date -d "yesterday" +"backup-%Y-%m-%d.sql.gz")

# Define the paths to the directories
backupDir="/home/backups"
sqlDir="/home/backups/sql"

folderToDelete="${backupDir}/${yesterdayDate}*"

if [ -d $folderToDelete ]; then
    echo "Deleting folder: $folderToDelete" | tee -a "$logFile"
    rm -rf $folderToDelete
    log "Deleted folder: $folderToDelete"
else
    echo "No folder starting with yesterday's date found." | tee -a "$logFile"
    log "No folder found starting with yesterday's date: $yesterdayDate"
fi

sqlFileToDelete="${sqlDir}/${yesterdayBackupFile}"
if [ -f "$sqlFileToDelete" ]; then
    echo "Deleting file: $sqlFileToDelete" | tee -a "$logFile"
    rm -f "$sqlFileToDelete"
    log "Deleted file: $sqlFileToDelete"
else
    echo "No .sql.gz file found for yesterday's date." | tee -a "$logFile"
    log "No .sql.gz file found for yesterday's date: $yesterdayBackupFile"
fi
