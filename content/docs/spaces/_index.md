---
title: Spaces
weight: 70
---

Spaces are running instances of templates. Each space is an isolated environment with its own compute resources, storage, and network configuration.

---

## What is a Space?

A space is a personal development environment created from a template. Think of templates as blueprints and spaces as the actual buildings constructed from those blueprints.

Each space includes:
- Container runtime environment
- Persistent storage volumes
- Network connectivity
- Access to configured features (SSH, terminal, Code Server)
- Isolated resources

---

## Space Lifecycle

**Created**
Space is defined but not running. Volumes are created. No resources consumed.

**Starting**
Container is being launched. Volumes are attached. Resources are being allocated.

**Running**
Space is active and accessible. Consumes compute units. All features available.

**Stopping**
Container is shutting down. Data in memory is lost. Volumes persist.

**Stopped**
Space is not running. Volumes remain intact. No compute units consumed.

**Deleted**
Space and all volumes are permanently removed. All data is lost.

---

## Resource Management

### Compute Units

**Running spaces** consume compute units based on template configuration. Users can run multiple spaces as long as total compute units stay within their quota.

**Stopped spaces** consume zero compute units. This allows you to preserve environments without using resources.

Example:
- User quota: 10 compute units
- Template A: 3 compute units
- Template B: 2 compute units
- Can run: 3 instances of Template A, or 5 instances of Template B, or 1 of A + 3 of B

### Storage Units

Storage units are consumed when a space is created, regardless of whether it's running or stopped. Storage units are based on volume sizes defined in the template.

### Space Limits

Users can be limited by:
- Maximum number of spaces (running + stopped)
- Total compute units (running spaces only)
- Total storage units (all spaces)

Group quotas combine with user quotas. If a user belongs to multiple groups, they get the sum of all quotas.

---

## Space Features

Depending on template configuration and user permissions, spaces can provide:

**Web Terminal**
Browser-based shell access to the space.

**SSH Access**
Secure shell access for IDE integration and command-line tools.

**Code Server**
VS Code in the browser for web-based development.

**VS Code Tunnel**
Connect desktop VS Code to the space.

**VNC Desktop**
Graphical desktop environment in the browser.

**Port Forwarding**
Access services running in the space from your local machine.

**Tunnels**
Expose space services to the public internet.

**File Transfer**
Copy files between local machine and space.

---

## Multiple Spaces

Users typically run multiple spaces for different purposes:

- Feature development: `feature-auth`, `feature-api`
- Bug fixes: `bugfix-123`, `hotfix-prod`
- Testing: `test-integration`, `test-performance`
- Demos: `demo-client-a`, `demo-prospect`
- Experiments: `experiment-new-framework`

Each space is completely isolated with its own data and configuration.

---

## Space Sharing

Spaces can be shared with other users for collaboration. Shared users get:
- SSH access to the space
- Web terminal access
- View space details

The space owner retains full control and can revoke sharing at any time.

---

## What's Next

- [Managing Spaces](managing/)
- [SSH Access](ssh/)
- [Web Terminal](terminal/)
- [Port Forwarding](port-forwarding/)
