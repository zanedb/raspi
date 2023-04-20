#/bin/bash
now=$(date +"%Y-%m-%d")

echo 'Complete backup starting. Shutting down docker containers.'

echo '$ docker compose down'
docker compose down

# copy all homeassistant & homebridge files to a dir
echo '$ cp -r /etc/homebridge /etc/backup/homebridge'
cp -r /etc/homebridge /etc/backup/homebridge
echo '$ cp -r /etc/homeassistant /etc/backup/homeassistant'
cp -r /etc/homeassistant /etc/backup/homeassistant

# zip
# fyi this method of zipping preserves the file tree (meaning when you unzip you get /etc/backup/homebridge) but it's okay
# proper fix is to use -C flag (https://superuser.com/a/428281) but this works
echo "$ tar -czf /etc/backup/homebridge-backup-$now.tar.gz /etc/backup/homebridge --remove-files"
tar -czf /etc/backup/homebridge-backup-$now.tar.gz /etc/backup/homebridge --remove-files
echo "$ tar -czf /etc/backup/homeassistant-backup-$now.tar.gz /etc/backup/homeassistant --remove-files"
tar -czf /etc/backup/homeassistant-backup-$now.tar.gz /etc/backup/homeassistant --remove-files

# upload & delete
echo "$ rclone moveto local:/etc/backup/homebridge-backup-$now.tar.gz dropbox:/Backup/raspi/homebridge-backup-$now.tar.gz"
rclone moveto local:/etc/backup/homebridge-backup-$now.tar.gz dropbox:/Backup/raspi/homebridge-backup-$now.tar.gz
echo "$ rclone moveto local:/etc/backup/homeassistant-backup-$now.tar.gz dropbox:/Backup/raspi/homeassistant-backup-$now.tar.gz"
rclone moveto local:/etc/backup/homeassistant-backup-$now.tar.gz dropbox:/Backup/raspi/homeassistant-backup-$now.tar.gz

echo 'Backup complete.'

echo "Shit, might as well update while I'm at it. Hope this doesn't break anything!"
echo '$ docker compose pull'
docker compose pull

echo 'Update complete. Starting docker containers..'
echo '$ docker compose up -d'
docker compose up -d

echo 'Done. See you in a month!'