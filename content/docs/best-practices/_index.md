---
title: Best Practices
description: Guidelines for deploying and managing knot effectively, organized by topic.
type: Overview
tags: [configuration]
weight: 95
---

Guidelines for deploying and managing Knot effectively. Topic guides live in their own pages:

- [Security](security/) — authentication hardening, data protection, monitoring, network
- [Backup & Restore](backup-restore/) — every `knot backup` / `knot restore` flag plus an automation script
- [Access Control](/docs/access-control/) — roles, groups, quotas, and the permission reference
- [UI Customization](ui-customization/) — branding and logo configuration
- [Variables](variables/) — variable hygiene for templates

---

## Template Design

- **Keep templates simple.** Start minimal and add complexity as needed; simple templates are easier to maintain and troubleshoot.
- **Use descriptive names**: `ubuntu-python-dev`, `nodejs-testing`, `php-web-server`.
- **Define volumes for persistence** — home directories, project files, database data.
- **Document custom fields** so users understand what values to provide.

## Resource Units

Set units to match what the template actually consumes:

| Template class | Cores | Compute units | Storage units |
|---|---|---|---|
| Light (CLI tools, agents) | 1-2 | 1-2 | 1-2 |
| Medium (web stacks) | 2-4 | 3-5 | 3-5 |
| Heavy (builds, databases) | 4+ | 6+ | 6+ |

Set a **maximum uptime** that matches the use case — 8-12 hours for development, 1-2 hours for demos — and use schedules to stop spaces outside working hours.

## Maintenance

- **Version control template definitions** for tracking changes and rollback.
- **Test template changes** before rolling them out to users; a template update prompts existing spaces to restart.
- **Mark unused templates inactive** rather than deleting them, to preserve history.
- **Encourage cleanup** of stopped spaces that are no longer needed.
