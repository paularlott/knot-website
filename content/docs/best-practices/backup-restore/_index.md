---
title: Backup and Restore
weight: 170
---

Protect your **knot** configuration and data with backups.

---

## What Gets Backed Up

**Included**: Users, roles, groups, templates, spaces metadata, variables, API tokens, audit logs (optional), configuration values (optional)

**Not included**: Space volumes, container images, server configuration file

---

## Creating a Backup

### Basic Backup

Create an unencrypted backup:

```shell
knot backup --output backup.json
```

### Encrypted Backup

Create an encrypted backup (recommended):

```shell
knot backup --encrypt --output backup.enc
```

You will be prompted for an encryption password. Store this password securely as it is required for restoration.

### Include Audit Logs

Include audit logs in the backup:

```shell
knot backup --encrypt --include-audit --output backup.enc
```

### Include Configuration Values

Include server configuration values:

```shell
knot backup --encrypt --include-config --output backup.enc
```

### Full Backup

Create a complete backup with all optional data:

```shell
knot backup --encrypt --include-audit --include-config --output backup-full.enc
```

---

## Restoring from Backup

### Basic Restore

Restore from an unencrypted backup:

```shell
knot restore --input backup.json
```

### Restore Encrypted Backup

Restore from an encrypted backup:

```shell
knot restore --input backup.enc
```

You will be prompted for the encryption password used during backup creation.

### Selective Restore

Restore only specific data types:

```shell
# Restore only users and groups
knot restore --input backup.enc --users --groups

# Restore only templates
knot restore --input backup.enc --templates
```

Available options:
- `--users`: Restore users
- `--groups`: Restore groups
- `--roles`: Restore roles
- `--templates`: Restore templates
- `--spaces`: Restore space metadata
- `--variables`: Restore variables
- `--tokens`: Restore API tokens
- `--audit`: Restore audit logs

---

## Backup Strategies

**Retention**: Daily (7 days), Weekly (4 weeks), Monthly (12 months)

**Storage**: Local (quick recovery), Remote (disaster recovery), Cloud (redundancy)

**Testing**: Regularly verify backup integrity and test restore procedures



---

## Migration

1. Create full backup on old server
2. Install knot on new server
3. Restore backup
4. Update configuration
5. Verify data

---

## Automation

### Automated Backups

Create backup script:

```bash
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/knot-$DATE.enc"

# Create encrypted backup
knot backup --encrypt --include-audit --output "$BACKUP_FILE"

# Remove backups older than 7 days
find "$BACKUP_DIR" -name "knot-*.enc" -mtime +7 -delete

# Upload to remote storage
rsync -az "$BACKUP_FILE" backup-server:/backups/knot/
```

### Monitoring

Monitor backup success:
- Check backup completion
- Verify backup file size
- Alert on backup failures
- Track backup duration


