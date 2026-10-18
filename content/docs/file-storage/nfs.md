---
title: NFS Mounts
description: Mount file storage buckets as folders on macOS and Linux, and in Docker and Podman containers, with knot nfs-server.
type: Guide
tags: [storage]
weight: 25
---

{{< experimental-badge >}} NFS access is experimental: its behaviour and options may change in later releases.

`knot nfs-server` serves file storage over NFS, so buckets can be mounted as ordinary folders: in the macOS Finder and Terminal, on Linux, and as Docker and Podman volumes, without installing FUSE or anything else on the machine mounting them. It serves **NFSv4.0** and **NFSv3** on one port.

`knot nfs-server` is a client of a knot server, acting as the user of the API token it connects with, exactly as the `knot file` commands do. It runs wherever the `knot` command runs, as many times as wanted: one per user, one for your Mac and another for containers, each on its own port. The knot server itself runs no NFS server.

{{< tip "warning" >}}
NFS has no authentication of its own: anyone who can connect to `knot nfs-server` can reach every file its user can. It only accepts connections from the machine it runs on unless `--nfs-allow` says otherwise; widen that only to networks you trust.
{{< /tip >}}

---

## Starting the server

With a connection set up by `knot connect`, start a server on the standard NFS port:

```shell
knot nfs-server
```

It logs the address and the user it serves as, and runs until stopped with `Ctrl-C`, saving anything written but not yet saved before it exits. To use another connection, or a server and token directly, pass the usual options:

```shell
knot nfs-server --alias work
knot nfs-server --server https://knot.example.com --token <files-scoped API token>
```

Create a token with the **Files** scope for `knot nfs-server`, so it can reach files and nothing else.

| Option | Default | Description |
|---|---|---|
| `--nfs-listen` | `127.0.0.1:2049` | The address to serve on, or just a port, e.g. `4000`, for `127.0.0.1:4000`. |
| `--nfs-allow` | loopback | Addresses or CIDRs allowed to connect, e.g. `192.168.1.0/24`. |
| `--uid`, `--gid` | the user running it | Show every file as owned by this user and group. See [ownership](#ownership-and-permissions). |
| `--cache-dir` | none | Keep files read and written in this directory, so they need not be fetched again. |
| `--cache-size` | `1GB` | The most the cache may hold, e.g. `512MB` or `10GB`. |
| `--server`, `--token`, `--alias` | the `default` alias | The knot server and token to act as, as for other `knot` commands. |

The listen address, allowed addresses and cache can also be set with `KNOT_NFS_LISTEN`, `KNOT_NFS_ALLOW`, `KNOT_NFS_CACHE_DIR` and `KNOT_NFS_CACHE_SIZE`.

Several servers can run side by side on different ports, for example one for your Mac and one for containers that shows files as owned by root:

```shell
knot nfs-server --nfs-listen 2049
knot nfs-server --nfs-listen 2050 --uid 0 --gid 0
```

### What the export holds

The top level of the export holds your buckets, named as the **Files** page shows them: your own by their short name, those shared with you by their full name. Folders and files within them are the buckets' folders and files. Making a folder at the top level creates a bucket; removing an empty one deletes it.

Mount the whole export at `/`, or a single bucket or folder by its path, such as `/configs` or `/configs/app`.

---

## Mounting on macOS

Make a folder to mount on, then mount with NFSv4, which macOS prefers:

```shell
mkdir -p ~/knot
mount_nfs -o vers=4,tcp,port=2049 127.0.0.1:/ ~/knot
```

Or with NFSv3, which can mount a single bucket or folder:

```shell
mount_nfs -o vers=3,tcp,port=2049,mountport=2049,nolocks,noresvport,locallocks 127.0.0.1:/configs ~/knot
```

No `sudo` is needed when the folder mounted on is your own. Unmount with `umount ~/knot`.

macOS keeps extended attributes (Finder tags, quarantine and the like) in `._name` files on NFS. `knot nfs-server` keeps them but leaves them out of listings, so tools such as `rsync --delete` don't see them as extra files; removing a file removes its `._` file too.

---

## Mounting on Linux

Mount with NFSv4:

```shell
sudo mkdir -p /mnt/knot
sudo mount -t nfs4 -o vers=4.0,port=2049 127.0.0.1:/ /mnt/knot
```

Or with NFSv3:

```shell
sudo mount -t nfs -o vers=3,tcp,port=2049,mountport=2049,nolock 127.0.0.1:/ /mnt/knot
```

Mounting needs the NFS client tools (`nfs-common` on Debian and Ubuntu, `nfs-utils` on Fedora and Alpine). Unmount with `sudo umount /mnt/knot`.

---

## Docker and Podman volumes

Docker and Podman mount NFS themselves through the `local` volume driver, so a bucket can be a volume with nothing installed in the container and no extra privileges.

With Docker Desktop or OrbStack, containers run in a virtual machine: use `host.docker.internal` as the address, which reaches `knot nfs-server` listening on your Mac's loopback address. On Linux, use the address of the machine running `knot nfs-server`, and allow it with `--nfs-allow`.

An NFSv4 volume of the whole export:

```shell
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=host.docker.internal,port=2049,vers=4.0 \
  --opt device=:/ \
  knot-files

docker run --rm -it -v knot-files:/files alpine ls /files
```

An NFSv4 volume of one bucket, by its path:

```shell
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=host.docker.internal,port=2049,vers=4.0 \
  --opt device=:/configs \
  knot-configs
```

An NFSv3 volume:

```shell
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=host.docker.internal,port=2049,mountport=2049,nfsvers=3,tcp,nolock \
  --opt device=:/configs \
  knot-configs-v3
```

The same in a Compose file:

```yaml
services:
  app:
    image: alpine
    command: ["sleep", "infinity"]
    volumes:
      - knot-files:/files

volumes:
  knot-files:
    driver: local
    driver_opts:
      type: nfs
      o: addr=host.docker.internal,port=2049,vers=4.0
      device: ":/"
```

Podman takes the same options: `podman volume create --opt type=nfs --opt o=... --opt device=...`. Mounting NFS needs root, so it works with rootful Podman and a Podman machine, not rootless Podman on Linux.

The volume is mounted when a container using it starts. Removing the volume unmounts it; the files stay in their bucket.

### In knot templates

A Docker or Podman template can mount a bucket into each space by defining an NFS volume in its **Volumes**. See [NFS volumes](/docs/templates/local-containers/volume-spec/#nfs-volumes) in the volume specification.

---

## Ownership and permissions

Files show the owner and group stored on them by a `chown` (for example by `rsync -a` run as root), and otherwise the user and group running `knot nfs-server`, so on your own machine your files are yours. `--uid` and `--gid` make every file show as owned by the user and group given, whatever is stored: use `--uid 0 --gid 0` for containers that run as root, where tools such as git refuse folders owned by another user.

Modes and modification times are stored on the files and kept when they move; folders keep theirs on the marker object that holds an empty folder. What a client may do is decided by the user `knot nfs-server` acts as, not by the modes: a bucket shared read-only is read-only over NFS whatever its files' modes say.

---

## How files are saved

NFS writes a file a piece at a time; file storage keeps whole files. `knot nfs-server` holds what is written and saves the file when the client closes or syncs it, as clients do at `close()` and `fsync()`. A file written without either is saved once writes to it stop for a moment. A save that fails for a reason that may pass, such as the knot server being unreachable, is retried until it succeeds; one the server refuses, such as over quota, is reported to the client on its next write or sync.

A change to a large file (over 8 MiB) is sent as just the bytes that changed, not the whole file, so appending to a log or editing part of a large file costs what the change does.

With `--cache-dir`, files read or written are kept on local disk by their content's checksum, so reading a file again, or changing it again, needs nothing from the knot server but its description. A kept file is never stale: a file that changes elsewhere has another checksum.

Changes made elsewhere, through the web interface, the `knot file` commands, S3 or another `knot nfs-server`, reach the server at once through the knot server's change events, and show on the mount within a moment.

---

## NFSv4 or NFSv3

| | NFSv4.0 | NFSv3 |
|---|---|---|
| Ports | one (`port`) | the same port for mounting (`mountport`) |
| Locks (`flock`, `fcntl`) | yes, between clients of the same `knot nfs-server` | only within one client (`nolock`) |
| Mount a single bucket or folder | yes, by path | yes, by path |
| macOS | preferred | supported |

Use NFSv4 unless a client only speaks NFSv3.

---

## Limits

- **The last save wins.** Two clients of the same `knot nfs-server` share what is being written; through two different `knot nfs-server`s, or with another writer such as the web interface, a file changed in both places keeps whichever was saved last.
- **Locks are kept by each `knot nfs-server`**, so they don't hold against clients of another, or against other ways of changing files.
- **No hard links**, device files or sockets; symbolic links are supported.
- **Renaming a folder copies each file** to its new name and then removes the old, so it is not atomic, and takes time for a folder with many files.
- **Storage suits the same files as file storage does**: configuration, scripts, documents and artifacts, not databases or busy git working trees shared between machines.
