# Valheim server for ARM64

Experimental docker image to run an ARM64 Valheim server based on [pi4valheim by Evirth](https://github.com/Evirth/pi4valheim) and box64. The Valheim server runs under box64, while Steam downloads use Valve's native ARM64 steamcmd.

Note that platform specific ARM64 images are built, and are split via docker tag:
* arm64 - For generic arm64 targets
* pi4 - For Raspberry Pi 4
* pi5 - For Raspberry Pi 5
* rk3588 - For Rockchip RK3588/RK3588S targets on the Rockchip Kernel
* tegra-t194 - For Nvidia Jetson/Xavier boards

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
BACKUPS=4                       # Number of Valheim built-in (-backups) backups to keep, defaults to 4. Set to false to disable world backups (see below)
BACKUPSHORT=7200                # In seconds, how long to wait for first Valheim built-in backup, defaults to 7200
BACKUPLONG=43200                # In seconds, how long to wait for Valheim built-in backups AFTER the first one, defaults to 43200
CROSSPLAY=true                  # If set to true, will enable crossplay. defaults to being unset, so crossplay disabled
TZ=America/Chicago              # Timezone for the container, defaults to UTC
ADMINLIST_IDS="123 456"         # SteamIDs (space or comma separated) written to adminlist.txt in SAVEDIR
BANNEDLIST_IDS="123 456"        # SteamIDs written to bannedlist.txt in SAVEDIR
PERMITTEDLIST_IDS="123 456"     # SteamIDs written to permittedlist.txt in SAVEDIR
CPU_AFFINITY=4-7                # Pin the server to these CPU cores (taskset format). Defaults to 4-7 (the A76 cores) on rk3588, unset otherwise. Set empty to disable
```

Boolean values (`PUBLIC`, `CROSSPLAY`) accept `1`/`0`, `true`/`false` or `yes`/`no` in any case. The `*LIST_IDS` files are only written when the variable is set, so manual edits are kept otherwise.

For easier migration from [lloesche/valheim-server](https://github.com/lloesche/valheim-server), the following aliases are also accepted:

| Alias             | Same as    |
|-------------------|------------|
| SERVER_NAME       | NAME       |
| WORLD_NAME        | WORLD      |
| SERVER_PASS       | PASSWORD   |
| SERVER_PORT       | PORT       |
| SERVER_PUBLIC     | PUBLIC     |

### Performance

The server runs under box64 using its default settings, which detect Valheim's Mono runtime and apply suitable settings for it. Any `BOX64_*` [environment variable](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md) set on the container is passed to box64. If you experience crashes, the stricter (and much slower) settings previously used by this image can be restored with:
```
BOX64_DYNAREC_BIGBLOCK=0
BOX64_DYNAREC_STRONGMEM=3
```

On big.LITTLE SoCs the server is pinned to the fast cores by default via `CPU_AFFINITY` (currently the `rk3588` image, cores 4-7). When pinned, box64 reports only the pinned cores to the server (`BOX64_MAXCPU`), so its thread pools match. If running in Kubernetes, avoid CPU limits that throttle the container.

### World Backups

On top of Valheim's built-in backups, the container creates a backup of the `worlds_local` directory on startup and then periodically, modeled after the backup system in lloesche/valheim-server:
```
BACKUPS_INTERVAL=3600           # In seconds, how often to create a backup, defaults to 3600
BACKUPS_DIRECTORY=/opt/valheim/world/backups # Where backups are stored, defaults to SAVEDIR/backups
BACKUPS_MAX_AGE=3               # In days, backups older than this are removed, defaults to 3 (0 disables)
BACKUPS_MAX_COUNT=0             # Maximum number of backups kept, defaults to 0 (unlimited)
BACKUPS_ZIP=true                # Compress backups with zip, if false backups are stored as directories, defaults to true
PRE_BACKUP_HOOK=                # Command ran before a backup, @BACKUP_FILE@ is replaced with the backup path
POST_BACKUP_HOOK=               # Command ran after a backup, @BACKUP_FILE@ is replaced with the backup path
```

Set `BACKUPS=false` to disable them. To create a backup by hand, run `docker exec valheim-server valheim-backup`.

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
      - "2456-2458:2456-2458/tcp"
      - "2456-2458:2456-2458/udp"
    volumes:
      - "valheim-data:/opt/valheim"
    restart: unless-stopped

volumes:
  valheim-data:
    name: valheim-data
```

## Thanks to the following open source projects
- [pi4valheim (forked)](https://github.com/Evirth/pi4valheim)
- [lloesche/valheim-server](https://github.com/lloesche/valheim-server)
- [box64](https://github.com/ptitSeb/box64)
- [docker](docker.com)
