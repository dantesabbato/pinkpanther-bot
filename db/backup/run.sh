#!/bin/sh

# Backup directory and file
BACKUP_DIR="/backup"
BACKUP_FILE="$BACKUP_DIR/db_backup.sql"

# Database connection variables
DB_NAME=${DATABASE_NAME:-pink_db}
DB_USER=${DATABASE_USER:-pink}
DB_HOST=${DATABASE_HOST:-telegram-db}
DB_PASSWORD=${DATABASE_PASSWORD:-wx422a09}

export PGPASSWORD=$DB_PASSWORD
echo "Starting database backup for $DB_NAME..."

# Create a database dump and overwrite the previous backup file
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -f $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "Backup successfully created: $BACKUP_FILE"
else
  echo "Backup failed!" >&2
fi

unset PGPASSWORD