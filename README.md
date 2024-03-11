# Valheim server for ARM64

Experimental docker image to run an ARM64 Valheim server based on [pi4valheim by Evirth](https://github.com/Evirth/pi4valheim), box86 and box64.

Note that currently 3 different ARM64 images are built, and are split via docker tag:
* arm64 - For generic arm64 targets
* rk3588 - For Rockchip RK3588/RK3588S targets on the Rockchip Kernel
* tegra-t194 - For Nvidia Jetson/Xavier boards

## Create image (optional)

Building the image takes around 5~ minutes.
1. Ensure you have `qemu-user-static` installed on your host machine
2. Clone repo `git clone https://github.com/riptidewave93/arm64-valheim`
3. Build the image `docker build --platform linux/arm64 --tag arm64-valheim -f Dockerfile .`

## Run container

Note that on first boot it may take a bit to download Valheim server, and generate the world, so be patient!

### Environment Variables

These values describe your server:
```
PASSWORD=YourServerPassword     # Password for the server, THIS IS REQUIRED!!!
PUBLIC=0                        # 0 private / 1 public, defaults to 0
PORT=2456                       # Sets the port of the server, defaults to 2456
NAME=YourServerName             # Name of the server, defaults to My World
WORLD=YourWorldName             # Name of the wold file, defaults to default
SAVEINTERVAL=1800               # How often the world should save, defaults to 1800
SAVEDIR=/opt/valheim/world      # Directory for the game files, needs to be to a volume mount to prevent data loss!
LOGFILE=/opt/valheim/log.txt    # Logfile for the gameserver, if unset, logs to stdout
BACKUPS=4                       # Number of backups to keep, defaults to 4
BACKUPSHORT=7200                # In seconds, how long to wait for first world backup, defaults to 7200
BACKUPLONG=43200                # In seconds, how long to wait for world backups AFTER the first world backup, defaults to 43200
CROSSPLAY=TRUE                  # If set to TRUE, will enable crossplay. defaults to being unset, so crossplay disabled
```

### Run the docker image

```
docker compose up -d
```

Following command uses configuration from **docker-compose.yml** file:
```
version: "3"

services:
  valheim-server:
    image: ghcr.io/riptidewave93/arm64-valheim:arm64
    container_name: valheim-server
    environment:
      - PASSWORD=password
    ports:
      - "2456-2457:2456-2457/udp"
      - "2456-2457:2456-2457/tcp"
    volumes:
      - "valheim-data:/opt/valheim"
    restart: unless-stopped

volumes:
  valheim-data:
    name: valheim-data
```

## Thanks to the following open source projects
- [pi4valheim (forked)](https://github.com/Evirth/pi4valheim)
- [box86](https://github.com/ptitSeb/box86)
- [box64](https://github.com/ptitSeb/box64)
- [docker](docker.com)
