# Valheim server for ARM64

Experimental docker image to run an ARM64 Valheim server based on [pi4valheim by Evirth](https://github.com/Evirth/pi4valheim), box86 and box64.

Currently the image is using a compiled version of Box64 designed for NVIDIA Jetson boards.

## Create image (optional)

Building the image takes around 10 minutes.
1. Ensure you have `qemu-user-static` installed on your host machine
2. Clone repo `git clone https://github.com/riptidewave93/arm64-valheim`
3. Build the image `docker build --platform linux/arm64 --tag arm64-valheim -f Dockerfile .`

## Run container

### Environment Variables

These values describe your server:
```
PUBLIC=0                        # 0 private / 1 public, defaults to 0 for private
PORT=2456                       # Sets the port of the server, defaults to 2456
NAME=YourServerName             # Name of the server, defaults to My World
WORLD=YourWorldName             # Name of the wold file, defaults to default
SAVEDIR=/root/valheim_server    # Directory for the game files, needs to be to a volume mount to prevent data loss!
PASSWORD=YourServerPassword     # Password for the servier, if unset no password is applied
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
    image: evirth/valheim-server-pi4
    container_name: valheim-server
    environment:
      - SAVEDIR=/root/valheim_server
      # Add your other env settings here
    ports:
      - "2456-2457:2456-2457/udp"
      - "2456-2457:2456-2457/tcp"
    volumes:
      - "valheim-data:/root/valheim_server"
    restart: unless-stopped

volumes:
  valheim-data:
    name: valheim-data
```

### Live server log preview
```
sudo tail -f /var/lib/docker/volumes/valheim-data/_data/log.txt
```

## Thanks to the following open source projects
- [pi4valheim (forked)](https://github.com/Evirth/pi4valheim)
- [box86](https://github.com/ptitSeb/box86)
- [box64](https://github.com/ptitSeb/box64)
- [docker](docker.com)
