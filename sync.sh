#/bin/bash
echo 'Syncing backup directories for Home Assistant & homebridge.'

echo '$ rclone sync -P /etc/homebridge/backups dropbox:/Backup/homebridge'
rclone sync -P /etc/homebridge/backups dropbox:/Backup/homebridge

echo '$ rclone sync /etc/homeassistant/backups dropbox:/Backup/homeassistant'
rclone sync /etc/homeassistant/backups dropbox:/Backup/homeassistant

echo 'Done. See you tomorrow.'