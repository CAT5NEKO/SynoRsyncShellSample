if [ -f .env ]; then
    source .env
else
    echo ".env file not found"
    exit 1
fi

backup_dir="$BACKUP_DIR"
remote_host="$REMOTE_HOST"
backup_prefix="$BACKUP_PREFIX"
password_postgres="$PG_PASSWORD"
password_rsync="$RSYNC_PASSWORD"
log_file="$backup_dir/backup_log.txt"

echo "Backup started at $(date)" > $log_file

current_datetime=$(date +"%Y-%m-%d_%H-%M-%S")
backup_filename="$backup_prefix-$current_datetime.sql"

echo "$(date) - Switching to postgres user..." >> $log_file
sudo su - postgres -c "
    echo 'Executing pg_dumpall...' >> $log_file
    PGPASSWORD=$password_postgres pg_dumpall > $backup_dir/$backup_filename
    if [ $? -eq 0 ]; then
        echo 'pg_dumpall successful for $backup_filename' >> $log_file
    else
        echo 'pg_dumpall failed for $backup_filename' >> $log_file
        exit 1
    fi
"

echo "$(date) - Syncing $backup_filename to remote server..." >> $log_file
echo $password_rsync | rsync -av --password-file=<(echo $password_rsync) $backup_dir/$backup_filename $remote_host
if [ $? -eq 0 ]; then
    echo "$backup_filename synced successfully." >> $log_file
    rm -f $backup_dir/$backup_filename
    echo "$backup_filename deleted after successful transfer." >> $log_file
else
    echo "Rsync failed for $backup_filename" >> $log_file
    exit 1
fi

echo "Backup process completed at $(date)" >> $log_file
