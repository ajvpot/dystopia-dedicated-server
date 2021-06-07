# dystopia-dedicated-server

## Purpose

Provide a containerized version of Dystopia dedicated server for general public use.

## Configuration

1. Edit the `Dockerfile` ENVs at the bottom of the file to set the command line options for the game server.
1. Edit `etc\cfg\server.cfg` to taste, and optionally add SourceMod admins to `etc\addons\sourcemod\configs\admins.cfg`.  You may also add any additional SourceMod/Metamod files to the `etc\addons` folder and these items will be added to your container image.  Visit the SourceMod website for additional configuration details.

A tournament-style image can be created by commenting out the Metamod and SourceMod installation from the build image.

## Usage

### Suggested Software

- Docker Desktop: https://www.docker.com/products/docker-desktop

### Build and Run

```bash
docker container rm -f -v dystopia-dedicated-server && \
docker build -t dystopia-dedicated-server . && \
docker run -d -it \
  -p 27016:27016/tcp \
  -p 27016:27016/udp \
  -p 27006:27006/udp \
  --name dystopia-dedicated-server \
  dystopia-dedicated-server
```

### Connecting

If you are deploying this locally, the `Dystopia` server should appear under the `LAN` tab in the server browser, or you can use `connect localhost:27016` to connect directly from the in-game console.

### Attach to Server Console (Windows/Docker Desktop)

```bash
docker attach dystopia-dedicated-server
```

Detach with Ctrl+Z then Ctrl+C.

## Known Issues

- Enabling stats on the command line options will cause a `segfault` and the server will not boot.
	- Workaround (untested): you may attempt to use the `server.cfg` to re-enable them, or manually re-enable them once the server has fully initialized.

## Thanks

Special thanks to all Dystopia developers, past and present.  This mod is amazing in its depth, breadth and foresight.

Additional thanks to the OpenTTD reddit group for providing an example dockerfile, upon which the architecture of this one is based.
