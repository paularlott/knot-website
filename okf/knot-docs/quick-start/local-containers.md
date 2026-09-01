---
description: Deploy knot using Docker, Podman, or Apple Containers.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/quick-start/local-containers/
sources:
    - resource: https://getknot.dev/docs/quick-start/local-containers/
status: stable
tags:
    - installation
    - deployment
title: Local Containers
type: Overview
---
# Local Containers

Deploy knot with Local Containers for the simplest path to powerful development environments. No Nomad, Kubernetes, or other orchestrator required.

---

## Overview

Local Containers mode runs knot directly on Docker, Podman, or Apple Containers. You can deploy:

- **Single Server**: One machine managing all spaces
- **Multi-Server**: Multiple servers with automatic load balancing and node selection

### Key Benefits

- **Zero Additional Dependencies**: Just Docker, Podman, or Apple Containers
- **Fast Setup**: Running in under 5 minutes
- **Multi-Runtime Support**: Use Docker, Podman, or Apple Containers simultaneously
- **Automatic Node Selection**: Multi-server deployments automatically choose the best server
- **Leaderless Clustering**: No single point of failure with multi-server setups

### Supported Runtimes

| Runtime | Description | Platform | Notes |
|---------|-------------|----------|-------|
| **Docker** | Most common container runtime | Linux, macOS, Windows | Widely supported, mature ecosystem |
| **Podman** | Daemonless, rootless container engine | Linux, macOS, Windows | Enhanced security, Docker-compatible |
| **Apple Containers** | Native macOS containerization | macOS (Apple Silicon only) | Built into macOS, no additional software |

---

## Choose Your Path

### [Single Server Setup](local-containers/server-setup.md)
**Quick setup on one machine**

**Best for**:
- Individual developers
- Small teams (< 10 users)
- Testing and evaluation
- Local development

**Setup time**: ~5 minutes

### [Multi-Server Setup](local-containers/multi-server.md)
**Scale across multiple servers**

**Best for**:
- Growing teams (10+ users)
- High availability requirements
- Geographic distribution
- Resource isolation

**Setup time**: ~10 minutes

---

## What's Next

- [Server Setup](local-containers/server-setup.md) - Start with single-server setup
- [Multi-Server Setup](local-containers/multi-server.md) - Scale across multiple servers
- [Node Selection](local-containers/node-selection.md) - How servers are chosen for spaces
