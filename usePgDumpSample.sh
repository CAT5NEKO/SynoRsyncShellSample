# PgDumpAllしたものをNASに送り付ける場合を想定
#!/bin/bash

# 設定
backup_dir="/var/lib/postgresql/任意のバックアップディレクトリ"

# Change USERNAME your username and 0.1.2.3 to your IP of connect to NAS

remote_host="USERNAME@0.1.2.3::任意の/ディレクトリ"
backup_prefix="backup"
password_postgres="パスワード"
password_rsync="パスワード"
log_file="$backup_dir/backup_log.txt"

echo "Backup started at $(date)" > $log_file

current_datetime=$(date +"%Y-%m-%d_%H-%M-%S")

echo "Backup started at $(date)" > $log_file

backup_filename="$backup_prefix-$current_datetime.sql"

# postgresユーザーに切り替え
echo "$(date) - Switching to postgres user..." >> $log_file
sudo su - postgres -c "
    # パスワードを自動入力してpsqlバックアップの実行
    echo 'Executing pg_dumpall...' >> $log_file
    PGPASSWORD=$password_postgres pg_dumpall > $backup_dir/$backup_filename
    if [ $? -eq 0 ]; then
        echo 'pg_dumpall successful for $backup_filename' >> $log_file
    else
        echo 'pg_dumpall failed for $backup_filename' >> $log_file
        exit 1
    fi
"

# リモートサーバに rsync で転送
echo "$(date) - Syncing $backup_filename to remote server..." >> $log_file
echo $password_rsync | rsync -av --password-file=<(echo $password_rsync) $backup_dir/$backup_filename $remote_host
if [ $? -eq 0 ]; then
    echo "$backup_filename synced successfully." >> $log_file

    # 転送成功後、バックアップファイルを削除
    rm -f $backup_dir/$backup_filename
    echo "$backup_filename deleted after successful transfer." >> $log_file
else
    echo "Rsync failed for $backup_filename" >> $log_file
    exit 1
fi

echo "Backup process completed at $(date)" >> $log_file