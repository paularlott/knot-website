---
title: Quotas, Replication and Maintenance
description: File storage limits, how buckets replicate across the cluster, backups, and checking and repairing storage.
type: Guide
tags: [storage]
weight: 30
---

## Quotas

Each user and group has two file storage limits alongside the other resource limits:

- **File Storage (MB)**, the size of the files in buckets the user owns;
- **Maximum Buckets**, how many buckets the user may own.

A user's limit is their own value plus that of each group they belong to, for each of the two limits separately:

- If the total is **greater than `0`**, that is the limit. The server defaults are **not used**, not even as a floor or a ceiling.
- If the total is **`0`**, the server default applies: `default_quota_mb` for storage and `default_max_buckets` for buckets. Both default to `0`, which means unlimited.

So a user is unlimited only when their own value, every group's value and the server default are all `0`. Once a user or any of their groups has a non-zero value, that user has a limit and can't be made unlimited, as `0` on the user means "use the next level", not "no limit"; and while a server default is set, no user with `0` everywhere can be unlimited either. To give some users more, set a larger value on the user or on a group they belong to. See [Managing Users](/docs/access-control/users/) and [Managing Groups](/docs/access-control/groups/).

Usage is counted against the bucket's **owner** — files written by others into a shared bucket count against its owner. The parts of a multipart upload count as they arrive, so uploads that are never completed cannot exceed the quota. An upload that would exceed the owner's limit is refused (`413` from the API, `QuotaExceeded` over S3 on Knot Pro), as is creating a bucket beyond the limit (`TooManyBuckets` over S3). A transfer is refused if the new owner is over either limit, unless forced.

Quotas are enforced by the server receiving the write against its view of the cluster, so simultaneous uploads to different servers can overshoot a limit slightly.

The Users page shows each user's file storage and bucket use in the **Files** column, and the usage view shows both as bars against their limits.

---

## How Replication Works

- Bucket and file records are replicated by gossip, newest change wins. A bucket is identified by an id that never changes, so renames and transfers are a change to one record. If two servers create buckets with the same name at the same moment, both keep their files and the one created later is renamed with a suffix such as `-2`. Each server keeps them in an embedded database in the storage directory.
- File content is stored once per server by its SHA-256, so identical files share storage and copies cost nothing.
- Each change is gossiped as soon as it is made: a write waits at most 50 ms, so a burst of uploads travels in a few messages rather than one per file, and a single write goes out almost at once. The periodic reconcile below doesn't carry new changes, it only repairs messages that were lost.
- A server that learns of content it doesn't hold streams it over a direct connection from the server that wrote it, or any other server, and verifies the checksum. Content is never gossiped. A transfer that breaks resumes from where it stopped. A read that arrives before the content does fetches it on demand.
- Every 30 seconds each server reconciles with a random peer, and a server that rejoins reconciles straight away, so missed updates and outages heal on their own. Each bucket's records are summarised in 64 parts, and only the records of parts that differ are exchanged. A few changes in a bucket of a million files therefore move a few thousand records, not the whole bucket.
- Deletes are remembered for 3 days, the same as deleted records elsewhere in knot, so a server returning from an outage cannot bring deleted files back. A server offline for longer than that should have its storage directory cleared before rejoining, as it should for the rest of its data.
- Each server numbers the changes it applies to a bucket, its own and those gossiped from others, so a client can follow a bucket by asking for what changed since it last looked (`/api/files/changes/{bucket}`, used by `knot file sync --watch` and the VS Code extension) instead of listing it again. The numbering belongs to that server: a client that moves to another server, or follows one that stopped uncleanly (it renumbers on start-up), is told to read the bucket again in full.

## Backups

`knot admin backup` copies buckets, sharing, file details and every file's content, from the running server, into a folder; `knot admin restore` rebuilds a lost server from it, and `knot admin file ls` and `knot admin file restore` list the files in a backup and put one file or folder back without a full restore. It needs the **Backup Server** permission, which administrators don't have unless they are given it. See [Backup and Restore](/docs/best-practices/backup-restore/).

## Checking and Repairing

`knot admin file fsck` checks a running server's file storage for damage and can repair it:

```shell
knot admin file fsck --server https://knot.example.com --token $TOKEN            # report only
knot admin file fsck --server https://knot.example.com --token $TOKEN --repair   # and fix
knot admin file fsck --deep ...                                                  # also check every file's checksum
knot admin file fsck --repair --from-backup /backups/knot ...                    # and restore content nothing else holds
```

The token belongs to a user with the **Manage File Storage** permission, and `--from-backup` also needs **Backup Server**. Choose the server with `--server` and `--token`, or `--alias`, as for other commands. It finds:

- file content that is missing from the server, or the wrong size or (with `--deep`) checksum, such as after a disk failure or a restore of part of the storage directory;
- reference counts, the queue of content to fetch, the index of deleted files and bucket statistics that disagree with the file records;
- content files and records that nothing uses, and buckets whose owner was deleted.

With `--repair`, missing or damaged content is fetched from the other servers in the cluster, counts, indexes and statistics are rebuilt from the file records, and buckets of deleted users are removed. If no server holds some content, `--from-backup` restores it from a [backup](/docs/best-practices/backup-restore/) folder, checked against its checksum. A check never removes a file record, so a file whose content nothing holds is reported and stays listed, with reads failing, until you restore its content or delete it. Deleting such a file, or its bucket, always works. The command exits with an error while problems remain, so it can run from cron.

A server notices lost content only when a file is read or when fsck runs, so run it on each server after a disk problem. Writes pause briefly while counts are rebuilt, and only if they were wrong.

## Disk Cleanup

Nothing is left behind on disk:

- Deleting or overwriting a file removes its content an hour after no file references it (identical content shared by several files stays until the last goes). For that hour the bucket can take the content back without it being sent again, which is how a renamed file, or a change undone, is synced without uploading it. Content held this way doesn't count against quotas.
- Deleting a bucket, or a user and with them their buckets, removes its files' content and records straight away on every server.
- An hourly sweep, also run shortly after start-up, removes anything that slipped through: content no file references (for example after a crash between writing and recording it), temporary files of uploads and fetches abandoned for an hour, multipart uploads older than 7 days or whose bucket was deleted, and empty directories.
- Deletion records are removed once they are 3 days old, and the space of removed small files is reclaimed in the background.
- S3 multipart upload parts (Knot Pro) stay on the server that received them until the upload completes, so a client should send all parts of one upload to the same server (behind a load balancer, use sticky sessions).
