---
title: Quick Start
description: Quick start guide to getting knot up and running.
weight: 10
---

Get **knot** running in minutes. Choose the deployment path that matches your needs.

---

## Which Path Should I Choose?

### Standalone Mode

**Best for**:
- Individual developers
- Learning knot
- Small teams (< 10 users)
- Local development
- Quick testing

**Requirements**:
- Docker or Podman installed
- Single machine
- 5 minutes setup time

**Start here**: [Standalone Setup](standalone/)

---

### Nomad Cluster

**Best for**:
- Production deployments
- Large teams
- High availability needs
- Distributed teams
- Scalable infrastructure

**Requirements**:
- Existing Nomad cluster
- CSI storage drivers
- Ingress controller
- 30 minutes setup time

**Start here**: [Nomad Setup](nomad/)

---

### Desktop Client

**Best for**:
- Connecting to existing knot server
- SSH access to spaces
- Port forwarding
- Tunnel creation
- File transfers

**Requirements**:
- Access to knot server
- 2 minutes install time

**Start here**: [Client Installation](client/)

---

## What You'll Learn

**Standalone Path**:
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

## Next Steps

After completing quick start:
- [Configure access control](../access-control/)
- [Create more templates](../templates/)
- [Set up cluster mode](../configuration/cluster-mode/)
- [Enable security features](../security/)
