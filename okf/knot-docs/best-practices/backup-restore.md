---
description: Protect your knot configuration and data with backups.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/best-practices/backup-restore/
sources:
    - resource: https://getknot.dev/docs/best-practices/backup-restore/
status: stable
tags:
    - backup
title: Backup and Restore
type: Overview
---
# Backup and Restore

Back up a running server with `knot admin backup` and rebuild a lost one with `knot admin restore`. Both work through the server's API, so they run from anywhere with a token: no access to the server's host, its database or its configuration is needed. A backup is a folder; to get back one file or folder from it, without restoring everything, use `knot admin file ls` and `knot admin file restore`.

```shell
knot admin backup /backups/knot-20261007
knot admin restore /backups/knot-20261007 --server https://new.example.com
```

---

## Who Can Back Up

A backup holds everything: every user's password hash and API tokens, every file. It needs the **Backup Server** permission, which is **not** part of the Admin role: an administrator can't back up the server, or restore into it, unless they are also given a role that holds it. That way the people who run the server day to day are separate from the people, or the unattended job, who can read all of its data.

- A **new server** creates a **Backup User** role in its database, holding just this permission, and gives it, along with the Admin role, to its first user. It is an ordinary role: edit it, give it to others, or delete it if you'd rather not have it.
- A server upgraded from an earlier version gets no such role and nobody holds the permission. Create a role with **Backup Server** (Administration → Roles) and assign it to whoever should back up.
- Give an automated job its own user with only that role, and an [API token](../api-tokens.md) for it. Scope the token to **Backup** and it can reach the backup and restore endpoints and nothing else, so a token left in a cron job can't be used to sign in or change anything.
- Every backup and restore is recorded in the audit log, once when it starts and once when it ends, with the user and the number of records.

Choose the server with `--server` and `--token` (or `KNOT_SERVER` and `KNOT_TOKEN`), or with `--alias` to use one defined in your configuration file's `[client.connection.<alias>]` section, as for the other `knot` commands. With none of these the `default` alias is used.

---

## What Gets Backed Up

**Included**: templates, template variables, volume definitions, groups, roles, users, user API tokens, spaces (metadata), scripts, skills, slash commands, responses, configuration values, audit logs and, when the server has [file storage](../file-storage.md), every bucket, every file's details and every file's content.

**Not included**: the contents of space volumes, container images and the server configuration file.

---

## Creating a Backup

```shell
knot admin backup /backups/knot-20261007
```

The backup goes into a folder, which must be new, empty or hold an earlier backup. It looks like this:

```text
/backups/knot-20261007/
├── manifest.json        what the backup holds, written when it is complete
├── users.jsonl          one file of records for each kind
├── tokens.jsonl
├── templates.jsonl
├── file-buckets.jsonl
├── file-objects.jsonl
├── ...
└── content/aa/bb/<sha256>   file content, by checksum
```

The records are JSON lines, streamed from the server and written as they arrive, so a backup of any size needs little memory. File content is stored once however many files share it. A folder without a `manifest.json` is an unfinished backup. The end of each stream carries a count, so a stream cut short, even through a proxy, fails the backup instead of being kept.

**Run it again into the same folder to refresh the backup**: it is a sync, not a fresh copy. The records, which are small, are streamed afresh and replace the old ones only when the whole backup has been taken, so a refresh that fails leaves the previous backup as it was; file content, which is most of the data, is copied only if the folder doesn't already hold it, so a nightly backup of a large file store copies just what changed. Add `--prune` to remove content from the folder that no file refers to any more, so the folder mirrors the server; without it, content for deleted files stays, which keeps older files recoverable.

Backups survive a poor connection. A stream that breaks is retried with a growing pause, and a file whose transfer broke carries on from the byte it reached, so a large file isn't started again. A partial copy is also kept when the command is stopped, and running it again into the same folder carries on from what is there. Content is checked against its SHA-256 before it is kept.

The records are taken as they are when the backup starts and content is copied afterwards. A file replaced during the backup may no longer have its old content, which is reported, and the command exits with an error although everything else is saved.

By default everything is backed up. Passing any of the selection flags backs up only the items selected:

| Flag | Backs up |
|------|----------|
| `--templates`, `-t` | Templates |
| `--template-vars`, `-v` | Template variables |
| `--volumes`, `-l` | Volume definitions |
| `--groups`, `-g` | Groups |
| `--roles`, `-r` | Roles |
| `--users`, `-u` | Users |
| `--tokens`, `-k` | User API tokens |
| `--spaces`, `-s` | Spaces |
| `--scripts`, `-c` | Scripts |
| `--skills`, `-i` | Skills |
| `--commands` | Slash commands |
| `--responses`, `-p` | Responses |
| `--cfg-values`, `-o` | Configuration values |
| `--audit-logs` | Audit logs |
| `--files` | File storage: buckets, files and their content |
| `--no-content` | With file storage, the records of buckets and files but not their content |
| `--prune` | With file storage, remove content from the folder that no file refers to |

`--limit-user <username>` and `--limit-template <name>` restrict the backup to a single user or template; `--limit-user` also limits file storage to the buckets that user owns.

```shell
# Users with their tokens and spaces only
knot admin backup users-backup --users --tokens --spaces
```

### Encrypted Backups

The records include password hashes and API tokens. Pass a 32-byte key with `--encrypt-key` (`-e`) or `KNOT_BACKUP_ENCRYPT_KEY` to encrypt them, in blocks so a large backup is still read a block at a time. Store the key securely: it is required to restore, and to list files.

```shell
knot admin backup --encrypt-key "$KNOT_BACKUP_KEY" /backups/knot-20261007
```

File content is stored as it is, so protect the folder in any case.

---

## Restoring a Lost Server

To rebuild a server, install knot, start a **new server**, create its first user, and restore the backup into it with that user's token. A restore, like a backup, needs the Backup Server permission, and a new server's first user receives it (see above), so there is never a time when a server accepts a restore from anyone who asks.

```shell
# 1. Create the first user in the new server's web UI, and give it an API token.
#    Use a username and email that the backup doesn't contain: the backup's own
#    users are restored over the new server's, and one that clashes is refused.
# 2. Restore with that token:
knot admin restore /backups/knot-20261007 --server https://new.example.com --token "$TOKEN" --encrypt-key "$KNOT_BACKUP_KEY"
# 3. Log in as one of the restored users and delete the temporary one.
```

- The users, with their API tokens and passwords, come back in the backup, so the same logins work on the new server.
- The users are restored last, so a restore that stops part way can simply be run again with the same token.
- Without a token, or from a user without the Backup Server permission, a restore is refused, including on a server with no users.
- Records are saved over any the server already holds, by id. File records keep their timestamps, so a newer version of a bucket or file already on the server wins, and restoring the same backup twice changes nothing. Audit log entries are added, with new numbers, so restoring twice adds them twice.
- File content is uploaded for the files whose content the server doesn't hold, checked against its SHA-256. `--no-content` restores the records only; `knot admin file fsck --repair --from-backup` can bring the content in later.
- Protected template variables are encrypted with the server's `server.encrypt` key, so the new server needs the same key as the old one to read them.
- The restore ends with a summary and a non-zero exit status if any record or content could not be restored.

For a cluster, restore into the first server, then start the others and let them join: they take everything from it.

---

## Recovering Files

To get back files deleted or overwritten by mistake you don't need to restore anything. List what the backup holds, then restore just what you want into the running server:

```shell
knot admin file ls /backups/knot-20261007                       # the buckets
knot admin file ls /backups/knot-20261007 alice--docs:reports/  # a folder
knot admin file ls -r /backups/knot-20261007 alice--docs:       # everything below it

knot admin file restore /backups/knot-20261007 alice--docs:reports/q3.pdf
knot admin file restore -r /backups/knot-20261007 alice--docs:reports/
```

- Buckets are named in full, `<username>--<name>`, as they were when the backup was taken. `ls` works on the folder alone, with no server.
- Files go back to the bucket they came from, found by its id, so it works even after the owner was renamed. The bucket must still exist.
- **Nothing is replaced without your say-so.** A file that already exists is skipped and reported; add `--overwrite` to replace it. `--dry-run` (`-n`) shows what would be restored and changes nothing.
- `--to bucket:folder/` restores into another bucket or folder instead, for example to look at the files first.
- The files are written as the user the command connects as, who needs the **Manage File Storage** permission to write into other users' buckets. Content type and modification time are kept, and the owner's quota is charged.

Damaged or lost content on a server, as opposed to deleted files, is repaired with [`knot admin file fsck`](../file-storage/operations.md#checking-and-repairing), which fetches it from the cluster and, with `--from-backup`, from a backup folder.

---

## Backup Strategies

**Retention**: Daily (7 days), Weekly (4 weeks), Monthly (12 months)

**Storage**: Local (quick recovery), Remote (disaster recovery), Cloud (redundancy)

**Testing**: Regularly test restores against a non-production server

---

## Migration

1. Create a full backup of the old server.
2. Install knot on the new server, configure it and start it.
3. Restore the backup into it with `knot admin restore --server <new server>`.
4. Update the configuration, point your clients at it and verify the data.

---

## Automated Backups

Create a user with only a role holding the **Backup Server** permission, give it an API token scoped to **Backup**, and keep the token and the encryption key in the job's environment:

```bash
#!/bin/bash
export KNOT_SERVER=https://knot.example.com
export KNOT_TOKEN=...                # the Backup User's token
export KNOT_BACKUP_ENCRYPT_KEY=...   # 32 bytes

# One folder, synced each night: only new file content is copied, and content
# for deleted files is dropped
knot admin backup --prune /backups/knot || exit 1

# Keep dated copies of the small record files
DATE=$(date +%Y%m%d)
mkdir -p /backups/history/$DATE
cp /backups/knot/*.jsonl /backups/knot/manifest.json /backups/history/$DATE/
find /backups/history -mindepth 1 -maxdepth 1 -mtime +30 -exec rm -rf {} +

# Copy off site: only new content moves
rsync -az /backups/knot backup-server:/backups/
```

Alert on a non-zero exit status.

---

## Troubleshooting

| Symptom | Check |
|---------|-------|
| `No permission to back up the server` | The token's user needs a role holding the Backup Server permission. Admins don't have it unless given the Backup User role. |
| `token scopes do not permit this endpoint` | The token is scoped; it needs the **Backup** scope. |
| `Encrypt key must be 32 bytes long` | The `--encrypt-key` value must be exactly 32 bytes. |
| `the backup is encrypted: give the key` | The backup was made with `--encrypt-key`; give the same key to restore or list it. |
| `cannot decrypt the backup: wrong key, or the file is damaged` | The key is wrong, or the record file was changed or truncated. |
| `holds no complete backup: it has no manifest.json` | The backup didn't finish. Run it again into the same folder. |
| `is not empty and holds no backup` | `backup` needs a new or empty folder, or one that holds an earlier backup. |
| `the backup is complete except for the content of N files` | Those files were replaced or deleted during the backup, or no server holds their content; run `knot admin file fsck` on the server, then back up again. |
| `the backup lists N records, M were read` | A record file is damaged or was truncated. |
| `No permission to restore the server` (401/403) | The server already has users: restore needs a token with the Backup Server permission. |
| `the bucket ... no longer exists on the server` | `file restore` needs the bucket; create it, or restore into another with `--to`. |
