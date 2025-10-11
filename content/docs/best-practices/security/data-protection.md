---
title: Data Protection
weight: 30
---

Protecting data at rest and in transit.

---

## Encryption Keys

Generate strong encryption keys:

```shell
knot genkey
```

**Key management**:
- Store keys securely (password manager, secrets vault)
- Never commit keys to version control
- Rotate keys periodically
- Use different keys for different environments
- Backup keys securely

---

## Cluster Keys

Cluster mode requires shared keys:

```toml {filename=knot.toml}
[server.cluster]
key = "VF9hmdXZyzNF3rcP6M0P"
```

**Cluster key security**:
- Use strong, randomly generated keys
- Distribute keys securely to all nodes
- Rotate keys periodically
- Monitor for unauthorized cluster join attempts

---

## Database Security

**MySQL/MariaDB**:
- Use strong database passwords
- Create dedicated database user for knot
- Grant only necessary permissions
- Enable SSL/TLS for database connections
- Restrict database access to knot servers only
- Enable encryption at rest

**Redis/Valkey**:
- Set strong Redis password
- Use Redis ACLs for fine-grained access control
- Enable SSL/TLS for Redis connections
- Restrict Redis access to knot servers only

**BadgerDB**:
- Secure filesystem permissions on BadgerDB directory
- Regular backups with encryption
- Restrict access to server filesystem

---

## Backup Security

Encrypt backups to protect sensitive data:

```shell
knot backup --encrypt --output backup.enc
```

**Backup best practices**:
- Always encrypt backups
- Store backups in secure location
- Restrict access to backup files
- Test restore procedures regularly
- Implement backup retention policies

---

## Container Image Security

Use trusted container images:
- Pull from official registries
- Verify image signatures
- Scan images for vulnerabilities
- Keep images updated
- Use minimal base images

---

## Runtime Security

Configure secure container runtime:
- Run containers as non-root users
- Drop unnecessary capabilities
- Use read-only root filesystems where possible
- Implement resource limits
- Enable security profiles (AppArmor, SELinux)

---

## Data Residency

Control where data is stored:
- Use cluster zones for geographic distribution
- Ensure data stays in required regions
- Document data flows
- Implement data retention policies
