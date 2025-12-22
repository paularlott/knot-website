---
title: Node Selection
weight: 65
---

Node selection determines which server in the zone will host a space. Knot can automatically select the best server based on availability and runtime requirements, or you can manually specify a server during space creation.

---

## Overview

When multiple servers are available in a zone, you can choose where a space is deployed:
- **Automatic Selection** (default): Knot selects the best available server
- **Manual Selection**: You choose a specific server when creating the space

If only one server in the zone can run the space, that server is automatically selected.

---

## Automatic Selection

When creating a space, leave the server selection set to **Auto** to let Knot choose the best server.

### Selection Criteria

Knot evaluates servers in the zone and selects based on the following priorities:

1. **Runtime Requirements**
   - If the template specifies a container runtime, only servers with that runtime are considered
   - If no runtime is specified, Knot uses the configured preference order: Docker > Podman > Apple Containers

2. **Zone Affinity**
   - Only servers in the same zone as the request are considered for local containers (Docker, Podman, Apple Containers)
   - Nomad deployments are handled separately by the Nomad scheduler

3. **Load Balancing**
   - The server with the lowest number of allocated spaces is selected
   - If servers have equal load, one is chosen at random

### Runtime Detection and Configuration

Each server in the zone exposes which container runtimes it supports:
- **Docker**: Detected via `docker info`
- **Podman**: Detected via `podman info`
- **Apple Containers**: Detected via `container system status`

The runtime preference order is defined in your `knot.toml` configuration:

```toml {filename="knot.toml"}
[server.docker]
  host = "unix:///var/run/docker.sock"

[server.podman]
  host = "unix:///var/run/podman.sock"
```

Knot automatically detects available runtimes. The preference order is:
1. Docker
2. Podman
3. Apple Containers (macOS only)

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



## Node Affinity

Spaces can be configured with node affinity for persistent placement:

- **Automatic** (default): No specific server preference; Knot chooses based on current load
- **Manual**: Space is assigned to a specific server and will prefer that server on restart

Node affinity is stored with the space configuration and persists across space restarts.

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
- Verify servers are online and in the same zone
- Check that the required container runtime is available on at least one server
- Ensure your user has permissions to create spaces on the servers

### Server Not Listed

If an expected server doesn't appear:
- Confirm the server is in the same zone
- Verify the container runtime matches the template requirements
- Check the server's connectivity and agent status

### Wrong Server Selected

If automatic selection chooses an unexpected server:
- Review the runtime preference order in `knot.toml`
- Check current space allocation across servers
- Use manual selection to override automatic behavior
