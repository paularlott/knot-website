---
title: Backup and Restore
linkTitle: Backup / Restore
description: Protect your knot configuration and data with backups.
type: Overview
tags: [backup]
weight: 170
aliases:
  - /docs/troubleshooting/backup-restore/
---

Back up the knot database with `knot admin backup` and load it back with `knot admin restore`. Both commands connect directly to the database, so run them on a server host with the same configuration as the server (database settings and `server.encrypt` key), e.g. `knot admin backup --config /etc/knot/knot.toml backup.json`.

---

## What Gets Backed Up

**Included**: templates, template variables, volume definitions, groups, roles, users, user API tokens, spaces (metadata), scripts, skills, slash commands, responses, configuration values, audit logs and, when the server has [file storage](/docs/file-storage/), its buckets and file details. With `--files-dir` the content of every file is copied too (see [File Storage](#file-storage)).

**Not included**: the contents of space volumes, container images and the server configuration file.

Protected template variables are decrypted with the server's `server.encrypt` key when written to the backup and re-encrypted with the target server's key on restore. Use `--encrypt-key` to keep them out of a plain-text file.

---

## Creating a Backup

```shell
knot admin backup backup.json
```

By default everything is backed up (`--all`). Passing any of the selection flags backs up only the items selected:

| Flag | Backs up |
|------|----------|
| `--templates`, `-t` | Templates |
| `--template-vars`, `-v` | Template variables |
| `--volumes`, `-l` | Volume definitions |
| `--groups`, `-g` | Groups |
| `--roles`, `-r` | Roles |
| `--users`, `-u` | Users |
| `--tokens`, `-k` | User API tokens (with `--users`) |
| `--spaces`, `-s` | Spaces (with `--users`) |
| `--scripts`, `-c` | Scripts |
| `--skills`, `-i` | Skills |
| `--commands` | Slash commands |
| `--responses`, `-p` | Responses |
| `--cfg-values`, `-o` | Configuration values |
| `--audit-logs` | Audit logs |
| `--files` | File storage buckets, sharing and file details (needs the storage directory) |

`--limit-user <username>` and `--limit-template <name>` restrict the backup to a single user or template; `--limit-user` also limits file storage to the buckets that user owns.

```shell
# Users with their spaces and tokens only
knot admin backup --users --spaces --tokens users.json
```

### Encrypted Backups

Pass a 32-byte key with `--encrypt-key` (`-e`) or `KNOT_BACKUP_ENCRYPT_KEY`. Store the key securely — it is required to restore.

```shell
knot admin backup --encrypt-key "$KNOT_BACKUP_KEY" backup.enc
```

---

## Restoring from Backup

```shell
knot admin restore backup.json
knot admin restore --encrypt-key "$KNOT_BACKUP_KEY" backup.enc
```

Restore loads everything contained in the file; to restore a subset, create a backup with only those items. Restored records are saved by ID, overwriting matching records in the target database.

---

## File Storage

When the configuration sets `server.files.path` (or `--files-path` / `KNOT_FILES_PATH` is given), a full backup includes file storage: every bucket with its owner and sharing, and every file's name, size, checksum, content type, metadata and modification time. Deleted buckets and files are left out. The backup is read from the storage directory, so it can be taken while the server is running.

The backup file holds no file content. Add `--files-dir <dir>` to copy the content of every backed up file into an empty directory, laid out as `<bucket>/<key>` with each file's modification time:

```shell
knot admin backup --config /etc/knot/knot.toml --files-dir /backups/knot-files-$DATE backup.enc
```

```text
/backups/knot-files-20261003/
├── alice--docs/
│   ├── readme.md
│   └── reports/2026/q3.pdf
├── bob--logs/
│   └── app.log
└── .knot-conflicts/
    ├── index.txt
    └── 9209d6f6...
```

A key that can't be written as a path is copied to `.knot-conflicts/<sha256>` instead, and listed with its bucket and key in `.knot-conflicts/index.txt`. This covers:

- `a` and `a/b` both existing;
- keys differing only in case, on a case-insensitive filesystem;
- keys with an empty segment (`//`) or a backslash;
- names longer than 255 bytes.

`--files-dir` must name an empty or new directory, so use a new one for each backup. Only the backup file is encrypted by `--encrypt-key`; the copied files are written as they are, so protect the directory accordingly. A file whose content this server doesn't hold, such as one still replicating, is reported, and the backup exits with an error once the rest are copied. On a cluster, back up any one server; each holds every file.

### Restoring File Storage

Stop the server first. Restore opens the storage directory exclusively and refuses to run while a server is using it, before changing anything:

```shell
knot admin restore --config /etc/knot/knot.toml --files-dir /backups/knot-files-20261003 backup.enc
```

- Buckets and file details are merged into the storage directory. They keep their original timestamps, so a newer version already held, or on another server in the cluster, wins, and restoring the same backup twice changes nothing.
- With `--files-dir`, the content of each file is read from `<bucket>/<key>`, or from `.knot-conflicts`, and checked against its SHA-256 before it is stored. Content the server already holds is skipped.
- Without `--files-dir`, only the details are restored. A server that joins a cluster then fetches the missing content from the other servers. A standalone server lists the files but can't serve them until their content is restored.
- If the backup holds file storage but `--files-path` isn't set, file storage is skipped with a warning and the rest is restored.

To rebuild one server of a healthy cluster, you rarely need a backup: an empty storage directory fills itself from the other servers.

### Recovering Deleted or Overwritten Files

To get back files deleted or overwritten by mistake, copy them from the `--files-dir` export back into the bucket while the server runs; no restore is needed. A restore can't do this, as the deletion is newer than the backed up file and wins, but uploading the file again is a new change.

`knot file sync` uploads only files that are missing or differ from the export, leaving the rest alone:

```shell
# See what would be uploaded, then upload it
knot file sync /backups/knot-files-20261003/alice--docs alice--docs: --dry-run
knot file sync /backups/knot-files-20261003/alice--docs alice--docs:

# Or a single file or folder
knot file copy /backups/knot-files-20261003/alice--docs/reports/q3.pdf alice--docs:reports/
knot file copy -r /backups/knot-files-20261003/alice--docs/reports alice--docs:reports/
```

Files listed in `.knot-conflicts/index.txt` are named by checksum; copy each back to the bucket under the key the index gives. Don't use `--delete` here unless the bucket should match the backup exactly, as it removes files added since.

---

## Backup Strategies

**Retention**: Daily (7 days), Weekly (4 weeks), Monthly (12 months)

**Storage**: Local (quick recovery), Remote (disaster recovery), Cloud (redundancy)

**Testing**: Regularly test restores against a non-production server

---

## Migration

1. Create a full backup on the old server
2. Install knot on the new server and configure its database
3. Restore the backup with `knot admin restore`
4. Update the configuration and verify the data

---

## Automated Backups

```bash
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/knot-$DATE.enc"

# Create encrypted backup (key from KNOT_BACKUP_ENCRYPT_KEY), with file content
knot admin backup --config /etc/knot/knot.toml --files-dir "$BACKUP_DIR/knot-files-$DATE" "$BACKUP_FILE"

# Remove backups older than 7 days
find "$BACKUP_DIR" -maxdepth 1 -name "knot-*" -mtime +7 -exec rm -rf {} +

# Upload to remote storage
rsync -az "$BACKUP_FILE" "$BACKUP_DIR/knot-files-$DATE" backup-server:/backups/knot/
```

Alert on a non-zero exit status or an unexpectedly small backup file.

---

## Troubleshooting

| Symptom | Check |
|---------|-------|
| `Encrypt key must be 32 bytes long` | The `--encrypt-key` value must be exactly 32 bytes. |
| `Error unmarshalling backup file` | The file is encrypted and no key, or the wrong key, was given — or the file is corrupt. |
| `Error loading backup file` | The path is wrong or the file isn't readable. |
| Database connection errors | Run with the server's configuration file (`--config`) so the command uses the same database settings. |
| `No encryption key set` | Protected template variables need `server.encrypt` set in the configuration used by the command. |
| `backing up file storage needs --files-path` | `--files` or `--files-dir` was given without the storage directory; use the server's configuration or pass `--files-path`. |
| `the files directory ... must be empty` | `--files-dir` must be a new or empty directory. |
| `files have no content on this server` | Some files are still replicating to this server; back up again, or from another server. |
| `file storage in ... is in use; stop the server before restoring` | Stop the server using the storage directory, then restore. |
