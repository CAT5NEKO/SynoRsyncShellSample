if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

local_dir="$LOCAL_DIR"
remote_host="$REMOTE_HOST"
current_date=$(date +"%Y-%m-%d")
log_file="$LOG_FILE"

remote_dir="${remote_host}/files${current_date}"

echo "Rsync started at $(date)" > $log_file

echo "Syncing files from $local_dir to $remote_dir..." >> $log_file
rsync -av $local_dir $remote_dir
if [ $? -eq 0 ]; then
    echo "Rsync successful for files at $current_date." >> $log_file
else
    echo "Rsync failed for files at $current_date." >> $log_file
    exit 1
fi

echo "Rsync completed at $(date)" >> $log_file
