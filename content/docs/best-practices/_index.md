---
title: Best Practices
weight: 150
---

Guidelines for deploying and managing **knot** effectively, organized by topic.

---

## Template Design

### Keep Templates Simple

Start with minimal configurations and add complexity as needed. Simple templates are easier to maintain and troubleshoot.

### Use Descriptive Names

Name templates clearly to indicate their purpose: `ubuntu-python-dev`, `nodejs-testing`, `php-web-server`.

### Set Appropriate Resource Limits

Balance performance with resource availability:
- Development: 2-4 CPU cores, 4-8GB RAM
- Testing: 1-2 CPU cores, 2-4GB RAM
- Demos: 1-2 CPU cores, 2GB RAM

### Define Volumes for Persistence

Always define volumes for data that should persist:
- User home directories
- Project files
- Database data
- Configuration files

### Use Template Variables

Leverage variables for flexibility:
- System variables for user info and server details
- User-defined variables for shared configuration
- Custom variables for per-space customization

### Document Custom Fields

Provide clear descriptions for custom fields so users understand what values to provide.

---

## Resource Management

### Set Compute Units Appropriately

Assign compute units based on resource consumption:
- Light templates (1-2 cores): 1-2 units
- Medium templates (2-4 cores): 3-5 units
- Heavy templates (4+ cores): 6+ units

### Configure Storage Units

Set storage units based on volume sizes:
- Small (1-10GB): 1-2 units
- Medium (10-50GB): 3-5 units
- Large (50GB+): 6+ units

### Set Maximum Uptime

Prevent runaway costs and resource waste:
- Development: 8-12 hours
- Testing: 2-4 hours
- Demos: 1-2 hours
- Long-running: 24+ hours or unlimited

### Use Schedules

Automatically stop spaces outside working hours to save resources.

---

## Access Control

### Use Groups for Organization

Create groups by team, project, or purpose:
- `developers`: Access to development templates
- `qa-team`: Access to testing templates
- `contractors`: Limited access to specific templates

### Create Specific Roles

Define roles with minimal necessary permissions:
- `developer`: Create and manage own spaces
- `qa-tester`: Create test spaces, view logs
- `admin`: Full system access

### Set Appropriate Quotas

Balance flexibility with resource limits:
- Developers: 3-5 spaces, 10-20 compute units
- QA: 2-3 spaces, 5-10 compute units
- Admins: Higher limits or unlimited

### Regular Access Reviews

Periodically review user access and remove inactive accounts.

---

## Security

### Use Strong Encryption Keys

Generate keys with `knot genkey` and store securely. Never commit keys to version control.

### Enable 2FA

Require two-factor authentication for all users, especially admins.

### Limit Network Exposure

Run knot on private networks. Use VPN for remote access. Only expose tunnel ports publicly if needed.

### Regular Updates

Keep knot updated to latest version for security patches and improvements.

### Secure Database

- Use strong database passwords
- Restrict database access to knot servers only
- Enable database encryption at rest
- Regular database backups

### Protect Sensitive Variables

Store sensitive data in user-defined variables marked as protected. Consider external secret management for highly sensitive environments.

---

## Deployment

### Use Cluster Mode for Production

Deploy multiple servers for high availability and geographic distribution.

### Place Servers Near Users

Reduce latency by deploying servers in regions close to your teams.

### Use Appropriate Storage Backend

- **BadgerDB**: Production-ready, works in single-server and multi-server clusters
- **MySQL/MariaDB**: Large-scale deployments, existing database infrastructure
- **Redis/Valkey**: High performance deployments

### Monitor Resource Usage

Track server and space resource consumption. Scale infrastructure before hitting limits.

### Regular Backups

Backup database and configuration regularly. Test restore procedures.

---

## Template Maintenance

### Version Control Templates

Store template definitions in version control for tracking changes and rollback capability.

### Test Template Changes

Test template modifications in non-production environments before deploying to users.

### Communicate Updates

Notify users when templates are updated, especially if changes affect existing spaces.

### Clean Up Unused Templates

Mark unused templates as inactive rather than deleting to preserve history.

---

## Space Management

### Encourage Regular Cleanup

Remind users to delete stopped spaces they no longer need.

### Use Descriptive Space Names

Name spaces to indicate purpose: `feature-auth`, `bugfix-123`, `demo-client-x`.

### Leverage Space Notes

Use notes to document space purpose, status, or important information.

### Share Spaces Appropriately

Share spaces for collaboration but be mindful of security and resource usage.

---

## Monitoring and Maintenance

### Review Logs Regularly

Check server logs for errors, warnings, and unusual activity.

### Monitor Cluster Health

In cluster mode, verify all nodes are connected and synchronizing properly.

### Track Resource Trends

Monitor resource usage over time to plan capacity and identify optimization opportunities.

### Clean Up Old Data

Periodically remove old audit logs, expired tokens, and unused volumes.

---

## Performance Optimization

### Use Local Volumes When Possible

Local volumes perform better than network storage for most workloads.

### Optimize Container Images

Use minimal base images and layer caching to reduce startup time.

### Configure Resource Limits

Set appropriate CPU and memory limits to prevent resource contention.

### Use Leaf Mode for Local Development

Developers can use leaf mode to run spaces locally while managing templates centrally.

---

## Disaster Recovery

### Document Configuration

Keep documentation of server configuration, network setup, and deployment procedures.

### Test Backup Restoration

Regularly test restoring from backups to verify they work.

### Have Rollback Plan

Document procedures for rolling back to previous versions if updates cause issues.

### Monitor Cluster Redundancy

Ensure cluster has sufficient redundancy to handle node failures.

---

## User Experience

### Provide Template Documentation

Document what each template includes and how to use it.

### Create Onboarding Templates

Provide simple, well-documented templates for new users to learn the system.

### Offer Training

Train users on knot features, best practices, and troubleshooting.

### Gather Feedback

Regularly collect user feedback to improve templates and workflows.
