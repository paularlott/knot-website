---
description: Choose your deployment path and get knot running in minutes.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/quick-start/
sources:
    - resource: https://getknot.dev/docs/quick-start/
status: stable
tags:
    - installation
    - deployment
title: Quick Start
type: Overview
---
# Quick Start

Get **knot** running in minutes. Choose the deployment path that matches your needs.

---

## Recommended: Config Wizard

### [Using the Config Wizard](quick-start/config-wizard.md)
**Fastest way to get started**

Run `knot server config-wizard` to generate a `knot.toml` through a guided web UI that walks you through each decision — database, networking, DNS, platforms, tunnel, security, and optional features. Sensible defaults are applied based on your deployment type.

---

## Manual Setup

### [Local Containers](quick-start/local-containers.md)
**Recommended for most users**

- **Single Server**: Quick setup on one machine with Docker, Podman, or Apple Containers
- **Multi-Server**: Scale across multiple servers with automatic node selection and load balancing
- **No orchestrator required**: No Nomad, Kubernetes, or other dependencies needed
- **Setup time**: 5-10 minutes

**Best for**:
- Individual developers
- Small to medium teams
- Quick testing and evaluation
- Multi-server setups without Nomad complexity

### [Nomad Cluster](quick-start/nomad.md)
**For enterprise-scale deployments**

- Leverage existing Nomad infrastructure
- CSI storage drivers and ingress controllers
- Advanced job constraints and scheduling
- **Setup time**: 30+ minutes

**Best for**:
- Production deployments
- Large teams
- High availability needs
- Organizations with existing Nomad infrastructure

---

## Quick Comparison

| Feature | Local Containers | Nomad |
|---------|------------------|-------|
| Single Server | ✅ | ✅ |
| Multi-Server | ✅ | ✅ |
| Dependencies | Docker/Podman/Apple | Nomad, Consul, CSI |
| Setup Time | 5-10 min | 30+ min |
| Complexity | Low | High |

---

## What You'll Learn

**Local Containers Path**:
1. Install knot binary
2. Configure server
3. Create admin user
4. Create first template
5. Launch first space
6. Access via web terminal

**Nomad Path**:
1. Install knot binary
2. Configure for Nomad
3. Deploy to cluster
4. Create admin user
5. Create Nomad template
6. Launch space in cluster

---

## What's Next

After completing quick start:
- [Configure access control](access-control.md)
- [Create more templates](templates.md)
- [Set up multi-server clusters](configuration/cluster-mode.md)
- [Enable security features](best-practices/security.md)
