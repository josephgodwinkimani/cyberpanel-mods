#!/usr/bin/env bash

# RUn rclone copy all incremental backups at (/home/backups) to remote cloud e.g. gdrive, mega etc.
# This file is dropped in by https://github.com/josephgodwinkimani/cyberpanel at /usr/local/CyberCP

# If you are only copying a small number of files (or are filtering most of the files) and/or have a large number of files on the destination then 
# --no-traverse will stop rclone listing the destination and save time.

rclone copy --no-traverse "/home/backup" remote:backups
