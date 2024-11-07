# NASに送り付けるのみの場合を想定
#!/bin/bash

# 設定
local_dir="任意のディレクトリ"
remote_host="USERNAME@0.1.2.3::任意の/ディレクトリ"
current_date=$(date +"%Y-%m-%d")
password_rsync="パスワード"

log_file="/任意の/ディレクトリ/fileSend_log.txt"
echo "Rsync started at $(date)" > $log_file

remote_dir="${remote_host}/files${current_date}"

echo "Syncing files from $local_dir to $remote_dir..." >> $log_file
sshpass -p "$password_rsync" rsync -av $local_dir $remote_dir
if [ $? -eq 0 ]; then
    echo "Rsync successful for files at $current_date." >> $log_file
else
    echo "Rsync failed for files at $current_date." >> $log_file
    exit 1
fi

echo "Rsync completed at $(date)" >> $log_file

