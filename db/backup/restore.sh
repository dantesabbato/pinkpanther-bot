#!/bin/sh

# Backup file path
BACKUP_FILE="/backup/db_backup.sql"

# Database connection variables
DB_NAME=${DATABASE_NAME:-pink_db}
DB_USER=${DATABASE_USER:-pink}
DB_HOST=${DATABASE_HOST:-telegram-db}
DB_PASSWORD=${DATABASE_PASSWORD:-wx422a09}

export PGPASSWORD=$DB_PASSWORD

echo "Restoring database $DB_NAME from backup..."

# Restore the database using the latest backup
pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME --clean --if-exists -F c $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "Database restored successfully!"
else
  echo "Database restore failed!" >&2
fi

unset PGPASSWORD