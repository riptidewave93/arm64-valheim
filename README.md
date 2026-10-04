# Valheim server for ARM64

Docker image to run an ARM64 Valheim server originally based on [Evirth/pi4valheim](https://github.com/Evirth/pi4valheim) and box64. The Valheim server runs under box64, while Steam downloads use Valve's native ARM64 steamcmd.

Note that platform specific ARM64 images are built, and are split via docker tag:

* arm64 - For generic arm64 targets
* pi4 - For Raspberry Pi 4
* pi5 - For Raspberry Pi 5
* pi5-16k - For Raspberry Pi 5 with 16K memory pages
* rk3588 - For Rockchip RK3588/RK3588S targets on the Rockchip Kernel
* tegra-t194 - For Nvidia Jetson/Xavier boards

Images are published with the same tags to:

* Docker Hub: [`riptidewave93/arm64-valheim`](https://hub.docker.com/r/riptidewave93/arm64-valheim)
* GitHub: [`ghcr.io/riptidewave93/arm64-valheim`](https://github.com/riptidewave93/arm64-valheim/pkgs/container/arm64-valheim)

For example, to pull the Raspberry Pi 5 image:
```
docker pull riptidewave93/arm64-valheim:pi5
```
OR
```
docker pull ghcr.io/riptidewave93/arm64-valheim:pi5
```

## Environment Variables

Boolean values accept `1`/`0`, `true`/`false` or `yes`/`no` in any case. Aliases are the names used by [community-valheim-tools/valheim-server-docker](https://github.com/community-valheim-tools/valheim-server-docker), accepted to ease migrating.

| Name                | Alias           | Default    | Purpose                                                                                                         |
|---------------------|-----------------|------------|-----------------------------------------------------------------------------------------------------------------|
| `PASSWORD`          | `SERVER_PASS`   |            | Password for the server, **required**. Must be at least 5 characters, or the server refuses to start            |
| `PASSWORD_FILE`     | `SERVER_PASS_FILE` |         | Read the password from this file instead, e.g. a Docker secret like `/run/secrets/valheim_pass`                 |
| `PUBLIC`            | `SERVER_PUBLIC` | `1`        | Whether the server is listed in the server browser (boolean)                                                    |
| `PORT`              | `SERVER_PORT`   | `2456`     | UDP start port the server listens on                                                                            |
| `NAME`              | `SERVER_NAME`   | `My World` | Name shown in the server browser                                                                                |
| `WORLD`             | `WORLD_NAME`    | `default`  | Name of the world, which is its directory name in `worlds_local/`. If unset and only a `Dedicated` world (the community-valheim-tools/valheim-server-docker default) exists, that is used |
| `SAVEINTERVAL`      |                 | `1800`     | In seconds, how often the world is saved                                                                        |
| `SAVEDIR`           |                 | `/config`  | Where worlds and permission files are stored. Must be on a volume or the server refuses to start, see [Volumes](#volumes) |
| `ALLOW_NO_VOLUME`   |                 | `false`    | Start the server even if `SAVEDIR` is not on a volume. Your world is lost when the container is removed! (boolean) |
| `LOGFILE`           |                 |            | Log file for the server, e.g. `/opt/valheim/log.txt`. Logs to stdout if unset                                   |
| `BACKUPS`           |                 | `4`        | Number of Valheim built-in backups to keep. Set to `false` to disable [World Backups](#world-backups)           |
| `BACKUPSHORT`       |                 | `7200`     | In seconds, how long to wait for the first Valheim built-in backup                                              |
| `BACKUPLONG`        |                 | `43200`    | In seconds, how long to wait between Valheim built-in backups after the first one                               |
| `CROSSPLAY`         |                 | `false`    | Run the server on the crossplay backend, so players on any platform can join (boolean)                          |
| `SERVER_ARGS`       |                 |            | Additional arguments for the server, e.g. world modifiers like `-preset hard` or `-modifier raids none`        |
| `TZ`                |                 | `UTC`      | [Time zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for the container, e.g. `America/Chicago` |
| `PUID`              |                 | `0`        | User ID to run the server as. Ownership of `/opt/valheim` and `SAVEDIR` is updated to match on start           |
| `PGID`              |                 | `0`        | Group ID to run the server as                                                                                   |
| `ADMINLIST_IDS`     |                 |            | SteamIDs (space or comma separated) written to `adminlist.txt` in `SAVEDIR`                                     |
| `BANNEDLIST_IDS`    |                 |            | SteamIDs written to `bannedlist.txt` in `SAVEDIR`                                                               |
| `PERMITTEDLIST_IDS` |                 |            | SteamIDs written to `permittedlist.txt` in `SAVEDIR`                                                            |

The `*LIST_IDS` files are only written when the variable is set, so manual edits are kept otherwise.

### Performance

| Name           | Default                            | Purpose                                                                                   |
|----------------|------------------------------------|-------------------------------------------------------------------------------------------|
| `CPU_AFFINITY` | `4-7` on `rk3588`, unset otherwise | Pin the server to these CPU cores (taskset format). Set empty to disable                  |
| `BOX64_*`      |                                    | Passed to box64, see its [documentation](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md) |

On big.LITTLE SoCs the server is pinned to the fast cores by default via `CPU_AFFINITY` (currently the `rk3588` image, cores 4-7). When pinned, box64 reports only the pinned cores to the server (`BOX64_MAXCPU`), so its thread pools match. If running in Kubernetes, avoid CPU limits that throttle the container.

The server runs under box64 using its default settings, which detect Valheim's Mono runtime and apply suitable settings for it. Any `BOX64_*` [environment variable](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md) set on the container is passed to box64. If you experience crashes, the below vars have been noted historically to help stability at the cost of speed/performance.
```
BOX64_DYNAREC_BIGBLOCK=0
BOX64_DYNAREC_STRONGMEM=3
```

### World Backups

On top of Valheim's built-in backups, the container creates a backup of the `worlds_local` directory on startup and then periodically, modeled after the backup system in community-valheim-tools/valheim-server-docker:

| Name                | Default            | Purpose                                                                                |
|---------------------|--------------------|----------------------------------------------------------------------------------------|
| `BACKUPS_INTERVAL`  | `3600`             | In seconds, how often to create a backup                                               |
| `BACKUPS_CRON`      |                    | Cron schedule for backups, e.g. `5 * * * *`. Overrides `BACKUPS_INTERVAL`              |
| `BACKUPS_DIRECTORY` | `$SAVEDIR/backups` | Where backups are stored                                                               |
| `BACKUPS_MAX_AGE`   | `3`                | In days, backups older than this are removed. `0` disables                             |
| `BACKUPS_MAX_COUNT` | `0`                | Maximum number of backups kept. `0` is unlimited                                       |
| `BACKUPS_ZIP`       | `true`             | Compress backups with zip, otherwise backups are stored as directories (boolean)       |
| `PRE_BACKUP_HOOK`   |                    | Command ran before a backup, `@BACKUP_FILE@` is replaced with the backup path          |
| `POST_BACKUP_HOOK`  |                    | Command ran after a backup, `@BACKUP_FILE@` is replaced with the backup path           |

Set `BACKUPS=false` to disable them. To create a backup by hand, run `docker exec valheim-server valheim-backup`.

### Automatic Updates

The container checks Steam for Valheim server updates periodically. When an update is found and no players are connected, the server is stopped (saving the world), backed up, updated and started again. Checks run using the following variables:

| Name                         | Default | Purpose                                                                                 |
|------------------------------|---------|-----------------------------------------------------------------------------------------|
| `UPDATE_INTERVAL`            | `900`   | In seconds, how often to check for updates. `0` disables update checks                  |
| `UPDATE_CRON`                |         | Cron schedule for update checks, e.g. `*/15 * * * *`. Overrides `UPDATE_INTERVAL`        |
| `UPDATE_IF_IDLE`             | `true`  | Only update when no players are connected (boolean)                                     |
| `UPDATE_IDLE_CHECKS`         | `5`     | Number of idle checks in a row needed before updating                                   |
| `UPDATE_IDLE_CHECK_INTERVAL` | `60`    | In seconds, time between idle checks                                                    |
| `IDLE_DATAGRAM_WINDOW`       | `3`     | In seconds, how long each idle check watches for traffic                                |
| `IDLE_DATAGRAM_MAX_COUNT`    | `30`    | Max UDP datagrams received during an idle check to still count as idle                  |
| `SERVER_STOP_TIMEOUT`        | `120`   | In seconds, how long to wait for the server to stop before killing it                   |
| `PRE_UPDATE_CHECK_HOOK`      |         | Command ran before each update check                                                    |
| `POST_UPDATE_CHECK_HOOK`     |         | Command ran after each update check                                                     |
| `PRE_RESTART_HOOK`           |         | Command ran after the server stopped for an update, before updating                     |
| `POST_RESTART_HOOK`          |         | Command ran after updating, before the server starts again                              |

Player counts can't be queried reliably (crossplay servers always report 0), so like community-valheim-tools/valheim-server-docker, the server is considered idle when it receives little UDP traffic.

To check for an update by hand, run `docker exec valheim-server valheim-updater check`. To apply an available update right away, even with players connected, run `docker exec valheim-server valheim-updater update`.

### Scheduled Restarts

The server can also be restarted on a schedule, the same way as for an update (stopped, backed up, updated if needed and started again):

| Name              | Default | Purpose                                                                                  |
|-------------------|---------|------------------------------------------------------------------------------------------|
| `RESTART_CRON`    |         | Cron schedule for restarts, e.g. `10 5 * * *` for daily at 5:10. Disabled if unset       |
| `RESTART_IF_IDLE` | `true`  | Only restart when no players are connected, using the same idle checks as updates (boolean) |

Cron schedules use the standard 5 fields (minute, hour, day of month, month, day of week) with numbers, `*`, ranges, steps and lists, in the container's `TZ`. Names like `MON` and shortcuts like `@daily` are not supported.

## Volumes

| Path           | Contents                                                                                                                       |
|----------------|--------------------------------------------------------------------------------------------------------------------------------|
| `/config`      | Your world (`worlds_local/`), the `adminlist.txt`, `bannedlist.txt` and `permittedlist.txt` files, and `backups/`. **Required**, the server refuses to start without a volume here (see `ALLOW_NO_VOLUME`). |
| `/opt/valheim` | The downloaded Valheim server and steamcmd. Optional, but saves downloading the server (~1 GB) on each fresh start.            |

To use an existing world, copy its directory (e.g. `%USERPROFILE%\AppData\LocalLow\IronGate\Valheim\worlds_local` on Windows) to `worlds_local/` in your `/config` volume, and set `WORLD` to the name of the world.

## Compose Example

Save the following as `docker-compose.yml`:
```yaml
services:
  valheim-server:
    image: riptidewave93/arm64-valheim:arm64
    container_name: valheim-server
    environment:
      - PASSWORD=password
      - NAME=My Server
      - WORLD=MyWorld
      - PUBLIC=1
      - CROSSPLAY=false
      - TZ=America/Chicago
      - ADMINLIST_IDS=76561198000000000
      - BACKUPS_MAX_AGE=7
    ports:
      - "2456-2458:2456-2458/tcp"
      - "2456-2458:2456-2458/udp"
    volumes:
      - "valheim-config:/config"
      - "valheim-data:/opt/valheim"
    # Give the server time to save the world when stopped
    stop_grace_period: 2m
    restart: unless-stopped

volumes:
  valheim-config:
    name: valheim-config
  valheim-data:
    name: valheim-data
```

Then start the server with:
```
docker compose up -d
```

The server saves the world when stopped, so `stop_grace_period` gives it time to do so before docker kills it (`--stop-timeout 120` with `docker run`). If running in Kubernetes, set `terminationGracePeriodSeconds` high enough for this to finish (e.g. 120), as the default of 30 seconds may not be enough.

## Building

The images are built with `make`, the same way CI builds them:
```
make all          # The base image and every variant
make pi5          # The base image and a single variant
make shellcheck   # Lint the scripts
```

Set `DOCKER=podman` to build with podman. Building on a host that isn't ARM64 needs QEMU user emulation set up for docker.

## Thanks to the following open source projects
- [pi4valheim by Evirth (forked)](https://github.com/Evirth/pi4valheim), itself based on [pi4valheim by thorkseng](https://github.com/tranko1/pi4valheim)
- [community-valheim-tools/valheim-server-docker](https://github.com/community-valheim-tools/valheim-server-docker)
- [box64](https://github.com/ptitSeb/box64)
- [box64-debs](https://github.com/ryanfortner/box64-debs)
- [docker](https://www.docker.com)
