---
title: Backup and Restore
weight: 70
---

Troubleshooting backup and restore issues.

---

## Backup Fails

**Symptom**: Backup command fails or produces errors.

**Solutions**:
- Check disk space for backup file
- Verify database connectivity
- Check file permissions on output directory
- Review error logs for specific issues
- Ensure knot server has read access to database

---

## Restore Fails

**Symptom**: Restore command fails or data not restored.

**Solutions**:
- Verify backup file integrity (not corrupted)
- Check encryption password is correct
- Ensure database is accessible and empty/clean
- Review compatibility between backup and current version
- Check file permissions on backup file
- Verify sufficient disk space

---

## Partial Restore

**Symptom**: Only some data restored successfully.

**Solution**: Try selective restore in order:
1. Restore users first
2. Then restore groups and roles
3. Finally restore templates and spaces

This helps identify which data type is causing issues.

---

## Encrypted Backup Won't Decrypt

**Symptom**: Cannot decrypt backup file.

**Solutions**:
- Verify encryption password is correct
- Check backup file is not corrupted
- Ensure backup was created with `--encrypt` flag
- Try restoring on same knot version that created backup
