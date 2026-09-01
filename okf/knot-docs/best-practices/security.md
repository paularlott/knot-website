---
description: Security considerations for deploying knot.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/best-practices/security/
sources:
    - resource: https://getknot.dev/docs/best-practices/security/
status: stable
tags:
    - security
title: Security
type: Overview
---
# Security

Security considerations for deploying Knot.

---

## Overview

Knot is designed for trusted environments. Deploy on private networks with VPN access for remote users.

**Key principles**:
- Defense in depth
- Principle of least privilege
- Regular security updates
- Comprehensive monitoring
- Incident preparedness

---

## Topics

- [Network Security](security/network.md) - Private networks, VPN, and firewall configuration
- [Authentication](security/authentication.md) - Passwords, 2FA, and API tokens
- [Data Protection](security/data-protection.md) - Encryption, backups, and database security
- [Monitoring](security/monitoring.md) - Audit logs, security events, and compliance

---

## Security Checklist

Before deploying to production:

- [ ] Strong encryption keys generated and secured
- [ ] Two-factor authentication enabled
- [ ] Database secured with strong passwords
- [ ] Network access restricted to private network or VPN
- [ ] Firewall rules configured
- [ ] SSL/TLS certificates configured
- [ ] Audit logging enabled
- [ ] Backup procedures tested
- [ ] User roles and permissions configured
- [ ] Resource quotas set
- [ ] Security monitoring in place
- [ ] Incident response plan documented
- [ ] Regular update schedule established
