---
description: Security monitoring, auditing, and compliance.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/best-practices/security/monitoring/
sources:
    - resource: https://getknot.dev/docs/best-practices/security/monitoring/
status: stable
tags:
    - security
    - logging
title: Monitoring and Compliance
type: Guide
---
# Monitoring and Compliance

Security monitoring, auditing, and compliance.

---

## Audit Logging

Audit events (authentication attempts, user and permission changes, template modifications, space lifecycle, configuration changes) are recorded automatically. Route them to your external logging service for long-term retention and compliance — the internal audit store is a convenience window that expires entries after the retention period:

```toml {filename=knot.toml}
[server]
audit_routing = "both"     # internal | external | both
audit_retention = 90       # days to keep audit logs in the internal store

[log.output]
url = "http://victorialogs:9428/insert/jsonline"
format = "ndjson"
```

See [Logging](../../configuration/logging.md) for the output options.

Audit events use the **username** as the actor for all authenticated actions; failed logins use the **submitted email address** (the identifier isn't known to be valid), and successful logins additionally carry the email in their properties — so you can correlate a failed-attempt burst with the account that eventually authenticated.

**What to monitor**:
- Authentication attempts (success and failure)
- User and permission changes
- Template modifications
- Space creation and deletion
- API access
- Configuration changes


Knot Pro adds built-in [anomaly detection](../../configuration/anomaly-detection.md) over the audit stream — failed-login bursts per user, credential spraying per source IP, and event sink failures — emitting `Anomaly Detected` audit events. It works with any `audit_routing` setting.


---

## Log Management

Implement proper log management:
- Centralize logs for analysis
- Set appropriate retention periods
- Protect logs from tampering
- Regular log review
- Alert on suspicious activity

---

## Security Monitoring

Monitor for security events:
- Failed authentication attempts
- Unusual access patterns
- Resource usage anomalies
- Unauthorized access attempts
- Configuration changes

---

## Incident Response

### Preparation

- Document incident response procedures
- Identify key personnel and contacts
- Maintain backup and recovery procedures
- Test incident response plans

### Detection

- Monitor logs and alerts
- Track unusual activity
- Review access patterns
- Investigate anomalies

### Response

- Isolate affected systems
- Preserve evidence
- Revoke compromised credentials
- Notify affected parties
- Document incident details

### Recovery

- Restore from clean backups
- Verify system integrity
- Update security controls
- Conduct post-incident review
- Implement preventive measures

---

## Compliance

### Privacy

Protect user privacy:
- Minimize data collection
- Secure personal information
- Implement data access controls
- Provide data export capabilities
- Document privacy practices

### Regulatory Requirements

Meet industry-specific requirements:
- Implement required security controls
- Maintain audit trails
- Enable encryption where required
- Regular security assessments
- Document compliance measures

---

## Security Updates

### Keep Software Updated

- Monitor release announcements
- Review changelogs for security fixes
- Test updates in non-production first
- Apply security patches promptly
- Subscribe to security advisories

### Dependency Management

- Update container images regularly
- Patch operating systems
- Update database software
- Monitor for vulnerability announcements
