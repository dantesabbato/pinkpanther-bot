#!/bin/bash
# Add a cron job to run the backup script every 6 hours
echo "0 */6 * * * /backup/run.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/db_backup_cron
# Set correct permissions for the cron job
chmod 0644 /etc/cron.d/db_backup_cron
# Apply the cron job
crontab /etc/cron.d/db_backup_cron
# Start cron in the foreground (this is important for Docker to keep the container alive)
cron -f