# Valheim server for ARM64

Experimental docker image to run an ARM64 Valheim server based on [pi4valheim by Evirth](https://github.com/Evirth/pi4valheim), box86 and box64.

## Create image (optional)

Building the image takes around 10 minutes.
1. Ensure you have `qemu-user-static` installed on your host machine
2. Clone repo `git clone https://github.com/riptidewave93/arm64-valheim`
3. Build the image `docker build --platform linux/arm64 --tag valheim-server -f Dockerfile .`

## Run container

### Configure the **server.env** file

These values describe your server:
```
PUBLIC=0                        # 0 private / 1 public
PORT=2456                       # Don't change if don't know what are you doing
NAME=YourServerName             # Your amazing name of your server
WORLD=YourWorldName             # Your unique name of your world
SAVEDIR=/root/valheim_server    # Where to save your data
PASSWORD=YourServerPassword     # You can leave blank and it will not have password
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
    env_file:
      - server.env
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
