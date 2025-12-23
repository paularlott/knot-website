---
title: Quick Start
description: Choose your deployment path and get knot running in minutes.
weight: 10
---

Get **knot** running in minutes. Choose the deployment path that matches your needs.

---

## Deployment Options

### [Local Containers](local-containers/)
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

### [Nomad Cluster](nomad/)
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

### [Desktop Client](client/)
**For connecting to existing servers**

- SSH access to spaces
- Port forwarding and tunnel creation
- File transfers
- **Setup time**: 2 minutes

**Best for**:
- Remote developers connecting to shared servers
- Users who don't need to run their own knot instance

---

## Quick Comparison

| Feature | Local Containers | Nomad | Client |
|---------|------------------|-------|--------|
| Single Server | ✅ | ✅ | ✅ |
| Multi-Server | ✅ | ✅ | N/A |
| Dependencies | Docker/Podman/Apple | Nomad, Consul, CSI | None |
| Setup Time | 5-10 min | 30+ min | 2 min |
| Complexity | Low | High | Very Low |

---

## Choosing Your Deployment

### Choose Local Containers if you:
- Want the quickest setup path
- Don't have (or want) Nomad infrastructure
- Need multi-server capacity without orchestrator complexity
- Prefer simpler operations and maintenance

### Choose Nomad if you:
- Already have a Nomad cluster
- Need advanced scheduling features
- Require CSI storage integration
- Have enterprise infrastructure requirements

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

**Client Path**:
1. Install client binary
2. Connect to server
3. Configure SSH
4. Access spaces

---

## What's Next

After completing quick start:
- [Configure access control](../access-control/)
- [Create more templates](../templates/)
- [Set up multi-server clusters](../configuration/cluster-mode/)
- [Enable security features](../best-practices/security/)
