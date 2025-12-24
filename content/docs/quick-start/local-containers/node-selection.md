---
title: Node Selection
description: How knot selects servers for space deployment in multi-server setups.
weight: 50
---

Node selection determines which server will host a space when multiple servers are available. Knot can automatically select the best server based on availability and runtime requirements, or you can manually specify a server during space creation.

---

## Overview

When multiple servers are available, you can choose where a space is deployed:
- **Automatic Selection** (default): Knot selects the best available server
- **Manual Selection**: You choose a specific server when creating the space

If only one server can run the space, that server is automatically selected.

---

## Automatic Selection

When creating a space, leave the server selection set to **Auto** to let Knot choose the best server.

### Selection Criteria

Knot evaluates servers in the zone and selects based on the following priorities:

1. **Runtime Requirements**
   - If the template specifies a container runtime, only servers with that runtime are considered
   - If no runtime is specified, Knot uses the configured preference order (defaults to Docker, Podman, Apple Containers)

2. **Zone Affinity** (optional)
   - If configured, only servers in the same zone as the request are considered
   - Useful for geographic distribution or logical separation
   - See [Multi-Server Setup](multi-server/) for zone configuration

3. **Load Balancing**
   - The server with the lowest number of allocated spaces is selected
   - If servers have equal load, one is chosen at random

### Runtime Detection and Configuration

Each server in the zone exposes which container runtimes it supports:
- **Docker**: Detected via `docker info`
- **Podman**: Detected via `podman info`
- **Apple Containers**: Detected via `container system status`

The runtime preference order is configured in your `knot.toml` configuration:

```toml {filename="knot.toml"}
[server.local_containers]
  runtime_pref = ["podman", "apple"]
```

This defaults to `["docker", "podman", "apple"]`. If a runtime isn't listed, it won't be used.

Each server in the zone exposes which container runtimes it supports:
- **Docker**: Detected via `docker info`
- **Podman**: Detected via `podman info`
- **Apple Containers**: Detected via `container system status`

Knot automatically detects available runtimes on each server.

{{< tip >}}
If a template specifies a container runtime, only that runtime is used regardless of the global preference order.
{{< /tip >}}

Only servers capable of running the space's required runtime are shown as options when creating a space.

---

## Manual Selection

To manually select a server for your space:

1. Navigate to the space creation dialog
2. In the server selection dropdown, choose a specific server instead of **Auto**
3. Complete the space creation as normal

### When to Use Manual Selection

- You need to place a space on a server with specific resources
- You're testing deployment on a particular server
- You have affinity requirements (e.g., database and application on the same server)
- A server has specialized hardware or configurations

{{< tip >}}
The space will always use the same server and can't be migrated to a different server.
{{< /tip >}}

---

## Cluster Considerations

In a multi-server cluster:

- Server load information is updated in real-time
- Automatic selection ensures even distribution across available servers

For high availability, consider:
- Distributing spaces across multiple servers
- Using manual selection for critical services
- Monitoring server resource utilization

---

## Troubleshooting

### No Servers Available

If no servers appear in the selection dropdown:
- Verify servers are online and part of the cluster
- Check that the required container runtime is available on at least one server

### Server Not Listed

If an expected server doesn't appear:
- Confirm the server is part of the zone (check logs)
- Verify the container runtime matches the template requirements
- Check the server's connectivity and agent status

### Wrong Server Selected

If automatic selection chooses an unexpected server:
- Review the runtime preference order in `knot.toml`
- Check current space allocation across servers
