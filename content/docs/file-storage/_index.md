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

Every server holds a full copy of every file, so reads are served locally and a server that is offline catches up when it returns. Because each file is stored on every server, file storage suits configuration, dotfiles, scripts and modest artifacts rather than bulk data; set [quotas](/docs/file-storage/operations/#quotas) to keep it that way.

---

## Enabling File Storage

File storage is off until a storage directory is set. Set it on each server that should store files:

```toml
[server.files]
path = "/var/lib/knot/files"
# default_quota_mb = 0    # quota only for users with no user or group limit, 0 = unlimited
# default_max_buckets = 0 # bucket limit only for users with no user or group limit, 0 = unlimited
```

| Setting | Flag / environment | Meaning |
|---|---|---|
| `path` | `--files-path` / `KNOT_FILES_PATH` | Storage directory. File storage, and on Knot Pro the S3 endpoint, are off when it is not set; remove it to turn them off. |
| `default_quota_mb` | `--files-default-quota-mb` / `KNOT_FILES_DEFAULT_QUOTA_MB` | Quota, in MB, used only for users whose own and group limits are all 0; any non-zero user or group value replaces it. Default `0` (unlimited). |
| `default_max_buckets` | `--files-default-max-buckets` / `KNOT_FILES_DEFAULT_MAX_BUCKETS` | How many buckets a user may own, used only when their own and group limits are all 0; any non-zero user or group value replaces it. Default `0` (unlimited). |

Every write is forced to disk before it is reported done, so a write that was reported successful survives a crash or power loss. Writes arriving together share one flush, so on fast drives such as NVMe the cost is small.

The directory holds an embedded database with the bucket and file metadata and the content of files up to 64 KB, a folder of files for larger content, and in-progress multipart uploads; give it room for every user's files. Keeping small files beside their metadata makes millions of small files cheap: the server starts within moments however many there are, and its memory use doesn't grow with their number. Servers without file storage answer file requests with `503 file storage is not enabled on this server` and don't serve `/s3`.

In a cluster, servers with file storage find each other automatically and replicate over the cluster's gossip port: a change to a bucket or file is gossiped as soon as it is made (within a fraction of a second), with a reconcile every 30 seconds as a safety net for anything missed, and a server missing a file's content streams it directly from a peer over the same port, encrypted with the cluster key. No extra ports or configuration are needed.

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

A bucket's name follows its owner's username. If an administrator changes a username, the user's buckets are renamed at once, `paul--configs` becoming `pauline--configs`, on every server, and shared users see the new name. The files, shares and quota are untouched, and each rename is recorded in the audit log as a **Bucket Rename**. Update scripts, sync jobs and S3 clients that use the old full name; the short name keeps working for the owner. In the unlikely case that the new name is already taken, the renamed bucket gets a suffix (`pauline--configs-2`).

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

An owner with the **Transfer Buckets** permission can give their bucket to another user, and a file storage manager can transfer any bucket. The bucket moves into the new owner's namespace and is **renamed**: `paul--configs` transferred to `bob` becomes `bob--configs`. Update any scripts, sync jobs or clients that use the old name. Files and shares move with it, nothing is copied, so even a bucket of millions of files transfers at once, and the old name is free again.

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

Should a user ever be deleted without their buckets going, each server notices within the hour and removes them, logging a warning. A bucket whose owner isn't in the user database at all is only logged, since a new user may not have replicated to that server yet; an administrator can transfer or delete it.

---

## More

- [Using Files](/docs/file-storage/using-files/): the Files page and the `knot file` commands
- [S3 Access](/docs/file-storage/s3/) {{< pro-badge >}}: use rclone, the AWS CLI or any S3 client
- [Quotas, Replication and Maintenance](/docs/file-storage/operations/): limits, how files replicate, backups, checking and repairing
