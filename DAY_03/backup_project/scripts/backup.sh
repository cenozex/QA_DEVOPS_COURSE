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


# ===== BACKUP MODULE =====
if pg_dump "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") Backup successful: $BACKUP_FILE" >> "$LOG_FILE"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") Backup FAILED for database: $DB_NAME" >> "$LOG_FILE"
fi


# ===== ROTATION MODULE =====
BACKUP_FILES=("$BACKUP_DIR"/backup_*.sql.gz)
FILE_COUNT=${#BACKUP_FILES[@]}

if [ "$FILE_COUNT" -le "$RETENTION_COUNT" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") No rotation needed. Total backups: $FILE_COUNT" >> "$LOG_FILE"
else
    FILES_TO_DELETE=$((FILE_COUNT - RETENTION_COUNT))
    echo "$(date +"%Y-%m-%d %H:%M:%S") Rotating $FILES_TO_DELETE old backup(s)" >> "$LOG_FILE"



# Delete the oldest backups
    for FILE in $(ls -1t "$BACKUP_DIR"/backup_*.sql.gz | tail -n "$FILES_TO_DELETE"); do
        rm -f "$FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") Deleted old backup: $FILE" >> "$LOG_FILE"
    done
fi
