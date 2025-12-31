#! /usr/bin/bash

echo "=========SCRIPT BY========="
echo "------------CENOZEX--------"

# ===== CONFIGURATION =====
BACKUP_DIR="/home/cenozex67/QA-DEVOPS_COURSE/DAY_03/backup_project/backups"
LOG_FILE="/home/cenozex67/QA-DEVOPS_COURSE/DAY_03/backup_project/logs/backup.log"
RETENTION_COUNT=5
DB_NAME="practiceDB"



# Ensure backup and log directories exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# ===== TIMESTAMP & FILENAME =====
TIMESTAMP=$(date +"%Y_%m_%d_%H_%M")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"



