# raspberrypi
_if `raspberrypi.local` links don't work, replace with local IP address (`ifconfig`) and look into bonjour/avahi issues._

[homebridge](http://raspberrypi.local:8581) | [home-assistant](http://raspberrypi.local:8123)

## contents

this repo contains all my docs for my personal raspberry pi setup. rn it's running homebridge (for my nest mostly) and home assistant (for everything else). after accidentally splitting my sd card in half i decided to document the next setup process just to be safe. so here it is. i also wrote some scripts that make my life easier.

- [`README.md`](#raspberrypi) - this. hi. i'm right here.
- [`docker-compose.yml`](https://github.com/zanedb/raspi/blob/main/docker-compose.yml) - my compose config. the only thing here you actually need to run this setup.
- [`sync.sh`](#configuring-automatic-backups) - syncs the automatic backups to dropbox nightly
- [`backup.sh`](#backup-backups) - zips and uploads the entire HA/HB directories to dropbox monthly. also updates the docker images.

## setup
```sh
ssh pi@raspberrypi.local
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sh
sudo apt-get install apt-transport-https ca-certificates software-properties-common -y
sudo usermod -aG docker pi
sudo curl https://download.docker.com/linux/raspbian/gpg
sudo nano /etc/apt/sources.list
# ⬆️ add `deb https://download.docker.com/linux/raspbian/ bullseye stable` on new line
sudo apt update && sudo apt upgrade -y && sudo apt autoremove
sudo systemctl start docker
sudo systemctl status docker # if it isn't working, try rebooting. running `dockerd` can also help
sudo mkdir /etc/homebridge && sudo mkdir /etc/homeassistant
# these two are just to get the docker-compose.yml
# you can also `nano docker-compose.yml` and copy and paste
git clone https://github.com/zanedb/raspi
cd raspi
docker compose up -d
```

## configuring automatic backups

homebridge backs up nightly by default, and [homeassistant can be configured to as well](https://jcwillox.github.io/hass-auto-backup/). then all you need is a cronjob that syncs them to your dropbox!

once you've setup rclone with both local and dropbox backends (`rclone config`), add [`sync.sh`](https://github.com/zanedb/raspi/blob/main/sync.sh) to your crontab (`crontab -e`). this runs every night at 5am, for example:

```sh
0 5 * * * /bin/sync.sh
```

## backup backups

for no reason at all you could even have [another backup going](https://github.com/zanedb/raspi/blob/main/backup.sh)! this one could run less frequently but contain more data. could save you time in the future! plus you already wrote that script before you found an easier way! even better, it can update your docker images too! bcause why not! life is nothing if not experimental!

```sh
0 7 1 * * /bin/backup.sh
```

## restoring from backup

this is what worked for me, your mileage may vary. hope it helps.

first, stop running containers:

```sh
docker compose down
```

### homeassistant

```sh
scp core_20xx_xx_xx.tar pi@raspberrypi.local:/home/pi # copy HA backup over
ssh pi@raspberrypi.local
tar -xvf core_20xx_xx_xx.tar # note the -v because it's not .tar.gz
tar -xzf homeassistant.tar.gz # now it is
sudo rm -rf /etc/homeassistant
sudo cp -r data /etc/homeassistant
rm core_20xx_x_x.tar homeassistant.tar.gz && rm -rf data # cleanup
docker compose up -d # start again!
```

### homebridge

if you're restoring from a homebridge-created backup to a docker image (like i was), it won't have the `node_modules` and won't install them for some reason. so you'll probably have to install the plugins in the dashboard, then reload your configuration so it finds your accessories. or maybe there's a better way? idk

```sh
scp homebridge-backup-xxxxxxxxxxx.tar.gz pi@raspberrypi.local:/home/pi # copy hb backup over
ssh pi@raspberrypi.local
tar -xzf homebridge-backup-xxxxxxxxxxx.tar.gz
sudo rm -rf /etc/homebridge && sudo cp -r storage /etc/homebridge
rm homebridge-backup-xxxxxxxxxxx.tar.gz plugins.json info.json && rm -rf storage # cleanup
docker compose up -d # woohoo!
```