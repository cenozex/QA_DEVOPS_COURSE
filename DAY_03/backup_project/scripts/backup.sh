#! /usr/bin/bash

echo "=========SCRIPT BY========="
echo "------------CENOZEX--------"

# ===== CONFIGURATION =====
BACKUP_DIR="/home/cenozex67/QA-DEVOPS_COURSE/DAY_03/backup_project/backups"
LOG_FILE="/home/cenozex67/QA-DEVOPS_COURSE/DAY_03/backup_project/logs/backup.log"
RETENTION_COUNT=5

DB_NAME="your_database_name"
DB_HOST="ip/address"      # hostname where it is hosted/IP
DB_PORT="portno"                 # PostgreSQL default port 5432
DB_USER="your_db_user"             # PostgreSQL user
PG_DUMP="absoultepath_to_pgdump"     # absolute path to pg_dump for cronjob for automation default : /usr/bin/pg_dump


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


# ===== START BACKUP =====
echo "$(date +"%F %T") Starting backup of $DB_NAME..." >> "$LOG_FILE"


# Ensure password-less authentication using ~/.pgpass
# Format of ~/.pgpass:
#This makes us easy to backup without manually writing password again and again which is best for cronjob
# remove the # below to configure for manual password authentication for DB
# hostname:port:database_name:database_username:database_password
export PGPASSFILE="$HOME/.pgpass"


# ===== BACKUP MODULE =====
if "$PG_DUMP" -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | awk '{print $1}')
    echo "$(date +"%F %T") Backup successful: $BACKUP_FILE (Size: $FILE_SIZE)" >> "$LOG_FILE"
else
    echo "$(date +"%F %T") Backup FAILED for database: $DB_NAME" >> "$LOG_FILE"
    rm -f "$BACKUP_FILE"
    rm -f "$LOCKFILE"
    exit 1
fi


# ===== ROTATION MODULE =====
BACKUP_FILES=("$BACKUP_DIR"/backup_*.sql.gz)
FILE_COUNT=${#BACKUP_FILES[@]}

if [ "$FILE_COUNT" -le "$RETENTION_COUNT" ]; then
    echo "$(date +"%F %T") No rotation needed. Total backups: $FILE_COUNT" >> "$LOG_FILE"
else
    FILES_TO_DELETE=$((FILE_COUNT - RETENTION_COUNT))
    echo "$(date +"%F %T") Rotating $FILES_TO_DELETE old backup(s)" >> "$LOG_FILE"

    # Safely handle spaces in filenames
    mapfile -t FILES_TO_DELETE_LIST < <(ls -1t "$BACKUP_DIR"/backup_*.sql.gz | tail -n "$FILES_TO_DELETE")
    for FILE in "${FILES_TO_DELETE_LIST[@]}"; do
        rm -f "$FILE"
        echo "$(date +"%F %T") Deleted old backup: $FILE" >> "$LOG_FILE"
    done
fi


# ===== CLEANUP LOCK FILE =====
rm -f "$LOCKFILE"
echo "$(date +"%F %T") Backup script finished." >> "$LOG_FILE"




# ===== CRON EXAMPLE (Add this line via `crontab -e`) =====
#======To check if it is added or not run 'crontab -l'=====
# Run hourly: 0 * * * * /home/$user/fullpath || Absoulte path is must for cron(Automation)
