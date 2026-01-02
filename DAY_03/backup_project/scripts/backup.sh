#! /usr/bin/bash

echo "=========SCRIPT BY========="
echo "------------CENOZEX--------"

# ===== CONFIGURATION =====
BACKUP_DIR="/home/cenozex67/QA-DEVOPS_COURSE/DAY_03/backup_project/backups"
LOG_FILE="/home/cenozex67/QA-DEVOPS_COURSE/DAY_03/backup_project/logs/backup.log"
RETENTION_COUNT=5

DB_NAME="practiceDB"
DB_HOST="192.168.31.198"      # hostname where it is hosted/IP
DB_PORT="5432"                 # PostgreSQL default port
DB_USER="postgres"             # PostgreSQL user
PG_DUMP="/usr/bin/pg_dump"     # absolute path to pg_dump for cronjob for automation


# ===== LOCK FILE TO PREVENT MULTIPLE RUNS =====
LOCKFILE="/tmp/db_backup.lock"
if [ -e "$LOCKFILE" ]; then
    echo "$(date +"%F %T") Backup already running, exiting." >> "$LOG_FILE"
    exit 1
fi
touch "$LOCKFILE"




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