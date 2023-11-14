# Valheim server for Raspberry Pi4 64-bit

Experimental docker image to run a Valheim server using Raspberry Pi4 based on [pi4valheim by thorkseng](https://github.com/thorkseng/pi4valheim), box86 and box64.

## Compiled image

You can find ready to use docker image on [Docker Hub](https://hub.docker.com/r/evirth/valheim-server-pi4).
> [!NOTE]
> Updated to **v0.217.30**

## Create image (optional)

Building the image takes around 10 minutes.
1. Clone repo `git clone https://github.com/Evirth/pi4valheim.git`
1. Build the image `docker build --no-cache --tag valheim-server -f Dockerfile .`

## Run container

### Configure the **server.env** file

These values should not be changed:
```
STEAMAPPID=892970
BOX64_LD_LIBRARY_PATH=./linux64:/root/steamcmd/linux32:$BOX64_LD_LIBRARY_PATH
BOX64_LOG=1
BOX64_TRACE_FILE=/root/valheim_server/output.log
BOX64_TRACE=1
```

These values describe your server:
```
PUBLIC=0                        # 0 private / 1 public
PORT=2456                       # Don't change if don't know what are you doing
NAME=YourServerName             # Your amazing name of your server
WORLD=YourWorldName             # Your unique name of your world
SAVEDIR=/root/valheim_server      # Where to save your data
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
- [pi4valheim (forked)](https://github.com/thorkseng/pi4valheim)
- [box86](https://github.com/ptitSeb/box86)
- [box64](https://github.com/ptitSeb/box64)
- [docker](docker.com)
