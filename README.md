[![GitHub Actions Docker Image CI](https://github.com/artkirienko/rehlds-docker-reunion/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/artkirienko/rehlds-docker-reunion/actions)
[![HitCount](http://hits.dwyl.com/artkirienko/rehlds-docker-reunion.svg)](http://hits.dwyl.com/artkirienko/rehlds-docker-reunion)

![banner](banner.png)

# reHLDS Docker reunion(47/48 Steam+noSteam)

## Half-Life Dedicated Server as a Docker image

Probably the fastest and easiest way to set up an old-school Half-Life
Deathmatch Dedicated Server (HLDS). Both Steam and noSteam, old and new
half-life clients can connect and play together! You don't need to know
anything about Linux or HLDS to start a server. You just need Docker and
this image.

## Quick Start

Start a new server by running:

```bash
docker run -it --rm -d -p27015:27015 -p27015:27015/udp artkirienko/rehlds
```

Change the player slot size, map or `rcon_password` by running:

```
docker run -it --rm -d --name hlds -p27015:27015 -p27015:27015/udp artkirienko/rehlds +map crossfire +maxplayers 12 +rcon_password SECRET_PASSWORD
```

> **Note:** Any [server config command](http://sr-team.clan.su/K_stat/hlcommandsfull.html)
  can be passed by using `+`. But it has to follow after the image name `artkirienko/rehlds`.

## What is included

* Latest game assets via **SteamCMD**
* [Reverse-engineered HLDS](https://github.com/dreamstalker/rehlds) version `3.7.0.695-dev`

  ```
  Protocol version 48
  Exe version 1.1.2.2/Stdio (valve)
  ReHLDS version: 3.7.0.695-dev
  Build date: 15:54:29 Apr  6 2020 (2186)
  Build from: https://github.com/dreamstalker/rehlds/commit/7513e71
  ```

* [Metamod-r](https://github.com/theAsmodai/metamod-r) version `1.3.0.128`

* [AMX Mod X](https://github.com/alliedmodders/amxmodx) version `1.9.0 build 5263`
  (development build, ReHLDS support)

* **reunion** version `0.1.0.92c`

* [revoice](https://github.com/s1lentq/revoice/) latest build. Voice transcoder
  which fixes voice chat between non-steam and steam clients (for ReHLDS).

* [jk_botti](https://github.com/Bots-United/jk_botti) version `1.43`

* Patched list of master servers (official and unofficial master servers
  included), so your game server appear in game server browser of all the clients

* Minimal config present, such as `mp_timelimit` and mapcycle

## Default mapcycle

* crossfire
* bounce
* datacore
* frenzy
* gasworks
* lambda_bunker
* rapidcore
* snark_pit
* stalkyard
* subtransit
* undertow
* boot_camp

## Advanced

In order to use a custom server config file, add your settings
to `valve/config/server.cfg` of this project and mount the directory as volume
to `/opt/steam/hlds/valve/config` by running:

```bash
docker run -it --rm -d -p27015:27015 -p27015:27015/udp -v $(pwd)/valve/config:/opt/steam/hlds/valve/config artkirienko/rehlds
```
