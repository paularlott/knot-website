---
title: File Storage
description: Store files in buckets replicated to every server in the cluster, from the web UI, the knot CLI, inside spaces, or (Knot Pro) any S3 client.
type: Overview
tags: [storage]
weight: 42
---

File storage keeps files in **buckets** that are replicated to every knot server in the cluster. Use it to share configuration files between spaces, hand files to teammates, or keep small artifacts close to where you work. Files can be reached through:

- the **Files** page in the web interface;
- the **`knot file`** commands, from your desktop or from inside a space with no configuration;
- the [**`knot.files`**](/reference/libraries/files/) scripting library, for scripts and MCP tools;
- the files **API** (`/api/files/*`);
- any **S3 client** (rclone, the AWS CLI, SDKs) at `<server>/s3` {{< pro-badge >}}.

Every server holds a full copy of every file, so reads are served locally and a server that is offline catches up when it returns. Because each file is stored on every server, file storage suits configuration, dotfiles, scripts and modest artifacts rather than bulk data; set [quotas](#quotas) to keep it that way.

---

## Enabling File Storage

File storage is off until a storage directory is set. Set it on each server that should store files:

```toml
[server.files]
path = "/var/lib/knot/files"
# sync = "always"         # "off" skips forcing writes to disk, see below
# default_quota_mb = 0    # quota for users with no user or group limit, 0 = unlimited
# default_max_buckets = 3 # bucket limit for users with no user or group limit, 0 = unlimited
```

| Setting | Flag / environment | Meaning |
|---|---|---|
| `path` | `--files-path` / `KNOT_FILES_PATH` | Storage directory. File storage, and on Knot Pro the S3 endpoint, are off when it is not set; remove it to turn them off. |
| `sync` | `--files-sync` / `KNOT_FILES_SYNC` | `always` (default) forces every upload and every change to disk before it is reported done. `off` doesn't. |
| `default_quota_mb` | `--files-default-quota-mb` / `KNOT_FILES_DEFAULT_QUOTA_MB` | Quota, in MB, for users whose own and group limits are all 0. Default `0` (unlimited). |
| `default_max_buckets` | `--files-default-max-buckets` / `KNOT_FILES_DEFAULT_MAX_BUCKETS` | How many buckets a user may own when their own and group limits are all 0. Default `3`; `0` means unlimited. |

With `sync = "always"` a write that has been reported successful survives a crash or power loss, and on fast drives such as NVMe the cost is small. With `off` it is much quicker for many small files on slow storage, but a crash or power loss can lose the last writes and, in the worst case, leave a file whose content is incomplete. In a cluster the other servers usually hold the data, and a server that lost writes catches up from them, but a write lost on the server that took it before it had been gossiped is gone. Keep `always` unless you have a reason; the setting doesn't change the data format and can be changed at any restart. Restoring from a backup always syncs.

The directory holds the file content, the bucket and file metadata, and in-progress multipart uploads; give it room for every user's files. Servers without file storage answer file requests with `503 file storage is not enabled on this server` and don't serve `/s3`.

In a cluster, servers with file storage find each other automatically and replicate over the cluster's gossip port: metadata is gossiped and reconciled every 30 seconds, and a server missing a file's content streams it directly from a peer over the same port, encrypted with the cluster key. No extra ports or configuration are needed.

### Leaf nodes

A leaf node's buckets are local to it. Files never replicate between a leaf and its origin servers, in either direction. Leaves reach their origin over the leaf protocol, which carries no file data. Each server also advertises whether it is an origin or a leaf and only exchanges files with servers of the same kind. On a leaf, every user has full use of their own buckets: creating, sharing and transferring them needs no permission, as with spaces on a leaf.

---

## Permissions

Every user can use the buckets shared with them or their groups, at the access the bucket's owner granted, with no permission needed. They find them with `knot file`, over S3 and on the Files page. The Files page appears for users who can own buckets or have at least one bucket shared with them. Owning buckets takes permissions:

| Permission | Allows |
|---|---|
| **Use File Storage** | Create your own buckets, work with their files and delete them. |
| **Share Buckets** | Share your own buckets with users, groups or everyone, and stop sharing them. |
| **Transfer Buckets** | Give your own buckets to another user. |
| **Manage File Storage** | Full access to every bucket, including sharing and transferring any bucket. |

The built-in Admin role has all four. A user who loses **Use File Storage** keeps only the access their buckets' grants give them; a file storage manager can transfer those buckets to someone else. S3 access on Knot Pro needs no separate permission: it reaches exactly the buckets the user can reach otherwise.

---

## Buckets

A bucket belongs to the user who creates it and is private until shared.

### Bucket names

Buckets are namespaced by their owner. You choose a short name of 3–30 lowercase letters, digits and hyphens, starting and ending with a letter or digit and without `--`. The bucket's full name is `<username>--<name>`, with the username lowercased. For example, `configs` created by `paul` is `paul--configs`.

- Refer to **your own** buckets by the short name (`configs`) or the full name (`paul--configs`).
- Refer to **buckets shared with you** by their full name (`alice--configs`).
- Lists show your own buckets by their short name and others' by their full name. This applies on the Files page, in `knot file bucket list` and in an S3 ListBuckets.

Usernames and short names never contain `--`, so the part before the first `--` is always the owner. Two users can each have a `configs` bucket.

```shell
knot file bucket create configs
knot file bucket list
knot file bucket info configs
knot file bucket delete configs            # must be empty
knot file bucket delete configs --force    # deletes its files too
```

### Sharing

The owner chooses, for each user, group or all users the bucket is shared with, whether they get **read-only** access (the default) or **read-write** (`--write`). Changing sharing needs the **Share Buckets** permission and is limited to the owner and file storage managers.

```shell
knot file bucket share configs --group platform-team
knot file bucket share configs --user alice --write
knot file bucket share configs --all
knot file bucket unshare configs --user alice
```

A bucket can be shared with up to 256 users and groups. Sharing with the same user or group again replaces their access, so `share --user alice` after `--write` makes Alice read-only again. Read access allows listing and downloading; write access also allows uploading, changing and deleting files. Buckets you can't access are invisible to you.

Alice then reaches the bucket by its full name:

```shell
knot file ls paul--configs:
knot file cat paul--configs:app/settings.toml
```

### Listing permissions

```shell
knot file bucket permissions configs
```

```
TYPE   NAME           ACCESS
owner  paul           owner
group  platform-team  read
user   alice          write
```

The owner and file storage managers see every grant; anyone else sees the owner and their own access. `knot file bucket list` shows your access to each bucket.

### Transferring

An owner with the **Transfer Buckets** permission can give their bucket to another user, and a file storage manager can transfer any bucket. The bucket moves into the new owner's namespace and is **renamed**: `paul--configs` transferred to `bob` becomes `bob--configs`. Update any scripts, sync jobs or clients that use the old name. Files and shares move with it, and the old name is free again.

The new owner needs the **Use File Storage** permission (or Manage File Storage) but not Transfer Buckets. The Files page lists only users who qualify. A file storage manager can also transfer a bucket to themselves, for example to take back one they gave away.

The content then counts against the new owner's quota. The transfer is refused in three cases:

- The new owner doesn't have permission to use file storage.
- The new owner is over their bucket or storage limit. A file storage manager can override this with `--force`.
- The new owner already has a bucket with that short name.

```shell
knot file bucket transfer configs bob
```

### Deleting a user

Deleting a user deletes the buckets they own, with their files, along with their spaces and other resources; their access to buckets shared with them is removed. Transfer any bucket worth keeping to another user first.

---

## The Files Page

**Files** in the sidebar lists the buckets you own or that are shared with you, with your access, size and your usage against your quota. Open a bucket to browse its folders, then:

- **Upload files** or **Upload folder**, or drag files and folders onto the list; progress is shown per file.
- **Download** any file, or **View**/**Edit** text files up to 1 MB in place. Saving is refused if someone else changed the file since you opened it, so no change is silently lost.
- **New file** creates a text file, with `/` in the name for folders.
- **Delete** files, or a folder and everything in it.

As the owner with **Share Buckets**, **Share** lists who has access, changes each grant between read only and read & write, removes grants and adds users, groups or all users. As the owner with **Transfer Buckets**, **Transfer** gives the bucket to another user and shows the name it will have. File storage managers can share and transfer any bucket and tick **Show all buckets** to see every bucket. Users with read-only access see only View and Download.

The page is keyboard and screen reader friendly and uses nothing from outside the knot server.

---

## Working with Files

A bucket's files are written `bucket:path`, e.g. `configs:app/settings.toml` for your own bucket or `alice--configs:app/settings.toml` for one shared with you; `configs:` on its own is the bucket itself. Any other path is local, so which way a copy goes follows from the arguments. Keys may contain `/` to organise files into folders, but not empty, `.` or `..` segments.

```shell
knot file ls                                   # your buckets (alias: list)
knot file ls configs:                          # one level of a bucket
knot file ls -r configs:app                    # everything below app/
knot file ls 'configs:app/*.toml'              # files matching a wildcard

knot file copy settings.toml configs:app/      # upload, keeping the name (alias: cp)
knot file copy settings.toml configs:app/main.toml   # upload under another name
knot file copy -r ./dotfiles configs:dotfiles/ # a directory and everything in it
echo "debug = true" | knot file copy - configs:app/debug.toml

knot file copy configs:app/settings.toml .     # download into the current directory
knot file copy configs:app/settings.toml ~/.config/app/main.toml
knot file copy -r configs:dotfiles ~/dotfiles
knot file copy configs:app/settings.toml -     # to stdout; so does: knot file cat configs:app/settings.toml

knot file copy configs:app/settings.toml backups:app/   # between buckets, on the server
knot file copy -r configs: backups:2026-10-05/

knot file rm configs:app/debug.toml            # alias: delete
knot file rm -r configs:old

knot file usage                                # usage against your quota
```

### How `copy` works

- **Direction.** A path of the form `bucket:path` is in a bucket, anything else is local, and `-` is stdin or stdout. A copy goes from the sources to the destination, the last argument; at least one side must be a bucket. A local path with a colon in its name is written with a leading `./` (`./notes:v2.txt`) so it isn't read as a bucket, and a bucket name is at least three characters, so a Windows drive such as `C:\` is always local.
- **Into a folder.** Several sources, a directory or folder source, or a wildcard need a destination that is a folder: an existing local directory (or one ending in `/`, which is created), or a bucket path ending in `/`, or just `bucket:`. A single file goes to the name you give it, so write the `/` to copy into a folder. Files already at the destination are replaced, and two sources that would land on the same destination are refused before anything is copied.
- **Folders.** `-r` copies a directory or bucket folder with everything below it. Its *contents* go into the destination folder, as with `rsync` and `rclone copy`, rather than the directory itself, so `copy -r ./site configs:site/` puts `./site/index.html` at `site/index.html`. Without `-r` a directory or folder is refused. Empty folders in a bucket become empty directories on download.
- **Wildcards.** `*` and `?` match within one name and `[abc]` a set of characters, as in a shell; `**` matches any number of folders. Quote a pattern for a bucket path, `'configs:logs/*.log'`, so the shell leaves it alone (an unquoted pattern with no match is an error in zsh). Unquoted local patterns are expanded by the shell as usual, and `copy` expands a quoted one itself. A pattern takes only files, unless `-r` is given, when a folder it matches is taken with everything below it. Files keep their path below the part of the pattern before the first wildcard: `'logs/**/*.log'` copies `logs/2026/10/a.log` as `2026/10/a.log`. To match a character that is a wildcard, put it in brackets: `a[*]b`.
- **Between buckets.** A copy from one bucket to another, or within one, happens on the server and moves no data, however large the files, and keeps their content type, metadata and modification time. You need read access to the source and write access to the destination, and the destination bucket's owner is charged for the new file against their quota.
- **Standard input and output.** `copy - bucket:path/file` uploads stdin as one file, and `copy bucket:path/file -` writes one file to stdout.

`rm` takes several paths and wildcards the same way: `knot file rm 'configs:logs/*.tmp' configs:old.txt`. A folder, or `bucket:`, needs `-r`, which deletes every file below it (the bucket itself stays; see `knot file bucket delete`). A path that matches nothing deletes nothing.

Uploads record the file's modification time and downloads restore it. Downloaded files are created readable by others (0644), or keep the mode of the file they replace.

Files fetched through the API are sent as attachments with a sandboxing `Content-Security-Policy`, so opening another user's HTML or SVG file in a browser downloads it rather than running it on the knot server.

### Syncing a directory

`knot file sync` makes a destination match a source, transferring only what differs, comparing files by size and SHA-256. Either side is a local directory or a bucket folder, and the direction follows from which is which:

```shell
knot file sync ./site configs:site                 # local -> bucket
knot file sync configs:site ./site                 # bucket -> local
knot file sync configs:site backups:site           # bucket -> bucket, on the server
knot file sync ./site configs:site --delete        # also remove files at the destination not in the source
knot file sync configs:site ./site -n              # dry run: show what would change
```

Modification times are kept in every direction. `--delete` removes files at the destination that aren't in the source. Between buckets only the files whose content differs are copied, with no data transferred, and folders in the same bucket that overlap are refused. `sync` takes folders, not wildcards.

**Which server.** Inside a space the commands discover the space's server and credentials through the agent — nothing to configure, so a space startup script can pull its configuration with `knot file copy`. On the desktop they use the connection saved by `knot connect`, choosing the server with `--alias` (default `default`). An explicit `--server`/`--token` pair overrides both, as with other knot commands.

---

## S3 Access {{< pro-badge >}}

On Knot Pro, every server with file storage also serves the S3 API, path-style, at `<server URL>/s3`, so rclone, backup tools, the AWS CLI and SDKs work with your buckets unchanged. Knot Core has the web interface, the `knot file` commands (including `sync`) and the API.

| Setting | Value |
|---|---|
| Endpoint | `https://knot.example.com/s3` |
| Access key | your username (or email) |
| Secret key | one of your [API tokens](/docs/api-tokens/) |
| Addressing | path-style |
| Region | any (`us-east-1` is reported) |

Create a token with the **Files** scope for S3 clients, so a leaked key can reach your files and nothing else. Any of your full-access tokens work too. Using a token for S3 keeps it alive, as API use does.

### rclone

```ini
[knot]
type = s3
provider = Other
endpoint = https://knot.example.com/s3
access_key_id = paul
secret_access_key = <files-scoped API token>
force_path_style = true
```

```shell
rclone lsd knot:
rclone sync ./site knot:configs/site
rclone check ./site knot:configs/site
```

Modification times, checksums, server-side copies and moves and multipart uploads all work.

### AWS CLI

```shell
export AWS_ACCESS_KEY_ID=paul
export AWS_SECRET_ACCESS_KEY=<files-scoped API token>
aws --endpoint-url https://knot.example.com/s3 s3 ls s3://configs/
aws --endpoint-url https://knot.example.com/s3 s3 cp ./build.tar.gz s3://configs/builds/
```

### Supported operations

ListBuckets, CreateBucket, HeadBucket, DeleteBucket (empty buckets), GetBucketLocation, ListObjects (v1 and v2), GetObject (with ranges and conditions), HeadObject, PutObject, CopyObject, DeleteObject, DeleteObjects and multipart uploads including UploadPartCopy (server-side copy in parts, used by the AWS CLI, boto3 and rclone for large objects), with signature version 4 in headers or presigned URLs and both signed and unsigned streaming payloads. Bucket sharing, transfer and quotas are managed with `knot file bucket` rather than S3 policies or ACLs; versioning, lifecycle rules, tagging and object locking are not supported.

Content is served with `X-Content-Type-Options: nosniff` and a sandboxing `Content-Security-Policy`, so an HTML or SVG file opened from a presigned URL can display but never run script against the knot server. Responses also carry `Cache-Control: no-transform`, so a reverse proxy that compresses responses (Caddy's `encode`, nginx `gzip`) leaves them untouched; S3 clients compare the exact bytes, ETags and ranges. File downloads through the API are marked the same way.

User metadata (`x-amz-meta-*` headers) is limited to 2 KB per file, as on AWS (`MetadataTooLarge`). File keys (up to 1024 bytes), metadata and content types must be valid UTF-8; anything else is refused with `400`, as it could not be stored and replicated unchanged. Parts of a multipart upload may be any size; the 5 MB minimum AWS applies is not enforced.

Buckets created over S3 belong to the signing user, as with `knot file bucket create`; creating `configs` makes `<username>--configs`. Bucket names in requests follow the [naming rules](#bucket-names): a short name is your own bucket, a full name reaches any bucket you have access to.

---

## Quotas

Each user and group has two file storage limits alongside the other resource limits:

- **File Storage (MB)**, the size of the files in buckets the user owns;
- **Maximum Buckets**, how many buckets the user may own.

A user's limit is their own value plus that of each group they belong to. When those add up to `0`, the server defaults apply: `default_quota_mb` (unlimited unless set) and `default_max_buckets` (3 unless set). See [Managing Users](/docs/access-control/users/) and [Managing Groups](/docs/access-control/groups/).

Usage is counted against the bucket's **owner** — files written by others into a shared bucket count against its owner. The parts of a multipart upload count as they arrive, so uploads that are never completed cannot exceed the quota. An upload that would exceed the owner's limit is refused (`413` from the API, `QuotaExceeded` over S3 on Knot Pro), as is creating a bucket beyond the limit (`TooManyBuckets` over S3). A transfer is refused if the new owner is over either limit, unless forced.

Quotas are enforced by the server receiving the write against its view of the cluster, so simultaneous uploads to different servers can overshoot a limit slightly.

The Users page shows each user's file storage and bucket use in the **Files** column, and the usage view shows both as bars against their limits.

---

## How Replication Works

- Bucket and file records are replicated by gossip, newest change wins. Each server keeps them in memory with a journal in the storage directory.
- File content is stored once per server by its SHA-256, so identical files share storage and copies cost nothing.
- Changes are gossiped in batches, so a burst of uploads travels in a few messages rather than one per file.
- A server that learns of content it doesn't hold streams it over a direct connection from the server that wrote it, or any other server, and verifies the checksum. Content is never gossiped. A transfer that breaks resumes from where it stopped. A read that arrives before the content does fetches it on demand.
- Every 30 seconds each server reconciles with a random peer, and a server that rejoins reconciles straight away, so missed updates and outages heal on their own. Each bucket's records are summarised in 64 parts, and only the records of parts that differ are exchanged. A few changes in a bucket of a million files therefore move a few thousand records, not the whole bucket.
- Deletes are remembered for 30 days so a server returning from a long outage cannot bring deleted files back; a server offline for longer should have its storage directory cleared before rejoining.

## Backups

`knot admin backup` includes buckets, sharing and file details, and with `--files-dir` copies every file's content into a directory as `<bucket>/<key>`; `knot admin restore` reads both back. See [Backup and Restore](/docs/best-practices/backup-restore/#file-storage).

## Disk Cleanup

Nothing is left behind on disk:

- Deleting or overwriting a file removes its content as soon as no file references it (identical content shared by several files stays until the last goes).
- Deleting a bucket, or a user and with them their buckets, removes its files' content and records straight away on every server.
- An hourly sweep, also run at start-up, removes anything that slipped through: content no file references (for example after a crash between writing and recording it), temporary files of uploads and fetches abandoned for an hour, multipart uploads older than 7 days or whose bucket was deleted, and empty directories.
- The metadata journal is compacted as it grows, dropping deletion records once they are 30 days old.
- S3 multipart upload parts (Knot Pro) stay on the server that received them until the upload completes, so a client should send all parts of one upload to the same server (behind a load balancer, use sticky sessions).
