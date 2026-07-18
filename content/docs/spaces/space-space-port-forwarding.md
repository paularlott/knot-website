---
title: Space-to-Space Port Forwarding
linkTitle: Space Forwarding
description: Forward ports between spaces in the same zone for direct service-to-service communication.
type: Guide
tags: [spaces, networking]
weight: 125
---

Space-to-space port forwarding allows spaces to communicate directly with each other. This is useful for microservices architectures where one space needs to access a service running in another space (for example, a frontend space connecting to a backend API space).

---

## Requirements

For space-to-space port forwarding to work:
- The source space must be running and have an active agent (or use `--persistent` to pre-configure a forward for when it starts)
- Spaces must be in the same zone
- Spaces must be owned by the same user
- Local port must be in the range 1-65535

## Commands

The following commands are run from inside a space using the knot agent:

### Forward Port

Forward a port from the current space to another space:

```shell
knot port forward <local-port> <space-name> <remote-port> [--persistent] [--force]
```

Example:
```shell
knot port forward 8080 backend-api 3000
```

This forwards port 8080 in the current space to port 3000 in the `backend-api` space.

- `--persistent` (`-p`): Persist the forward across agent restarts.
- `--force` (`-f`): Create the forward even if the target space is not currently running.

### List Active Forwards

View all active port forwards from the current space:

```shell
knot port list
```

Example output:
```
Active port forwards:
  8080 -> backend-api:3000 (persistent, direct)
  5432 -> database:5432 (temporary, relay)
```

The mode shown after the state indicates how traffic is routed:
- **direct** {{< pro-badge >}}: traffic flows directly between agents without going through the server
- **relay**: traffic is relayed through the knot server

Direct mode requires Knot Pro and both spaces running on the same host or network. When direct isn't available or fails, the forward automatically falls back to relay.

### Stop Port Forward

Stop an active port forward:

```shell
knot port stop <local-port>
```

Example:
```shell
knot port stop 8080
```

---

## Port Forward Throttling

Apply latency, jitter, and bandwidth limits to simulate real-world network conditions on any port forward.

### From Inside a Space

```shell
knot port throttle <local-port> [--latency Nms] [--jitter Nms] [--bandwidth NKB/s] [--reset]
```

Examples:
```shell
# Add 200ms latency with 50ms jitter
knot port throttle 3306 --latency 200ms --jitter 50ms

# Limit to 100 KB/s
knot port throttle 3306 --bandwidth 100

# Simulate slow, unstable connection
knot port throttle 3306 --latency 100ms --jitter 200ms --bandwidth 50

# Clear all limits
knot port throttle 3306 --reset
```

### From Desktop or Web UI (Pro)

```shell
knot space port throttle <space> <local-port> --latency 200ms --jitter 50ms
```

Or use the web UI {{< pro-badge >}}: open the space's port forwards panel, click edit on a forward, and set latency, jitter, and bandwidth values. Empty fields mean no limit.

### How It Works

- **Latency**: each direction gets the specified delay (e.g. 50ms each way = 100ms round trip)
- **Jitter**: random variance added to or subtracted from the latency, uniform distribution
- **Bandwidth**: proportional throttling per write, limiting throughput in both directions independently
- Settings are runtime-only: they do not persist across agent restarts and are not stored in the space record
- Throttling applies to both relay and direct connections equally
- Changes take effect immediately on existing connections (no need to recreate the forward)

`knot port list` shows active throttle settings:
```
Active port forwards:
  3306 -> db:3306 (persistent, direct, 200ms ±50ms 100KB/s)
  6379 -> cache:6379 (persistent, relay)
```

---

## Desktop Client Commands

The following commands are run from your desktop machine using the knot CLI:

### Forward Port

Forward a port from one space to another space:

```shell
knot space port forward <from-space> <from-port> <to-space> <to-port> [--persistent] [--force]
```

Example:
```shell
knot space port forward frontend 8080 backend-api 3000
```

This forwards port 8080 in the `frontend` space to port 3000 in the `backend-api` space.

- `--persistent` (`-p`): Persist the forward across agent restarts. Also allows creating a forward when the source space is not currently running.
- `--force` (`-f`): Create the forward even if the target space is not currently running.

### List Active Forwards

View all active port forwards from a specific space:

```shell
knot space port list <space-name>
```

Example:
```shell
knot space port list frontend
```

### Stop Port Forward

Stop an active port forward in a specific space:

```shell
knot space port stop <space-name> <local-port>
```

Example:
```shell
knot space port stop frontend 8080
```

{{< tip >}}
The desktop client commands require you to be authenticated with the knot server. Use `--server` and `--token` flags or configure them in your knot config file.
{{< /tip >}}

---

## Use Cases

- **Microservices Communication**: Connect frontend containers to backend services
- **Database Access**: Allow application containers to access database containers
- **Service Discovery**: Enable development environments that mirror production architectures

---

## Apply Port Forwards

Replace all port forwards for a space with a new set. This is useful for declarative configuration where you want to ensure the forwarding state matches a desired list.

### From a Space (Scripting)

```python
import knot.space as space

# Apply a set of port forwards, replacing any existing ones
result = space.port_apply("frontend", [
    {"local_port": 8080, "space": "backend-api", "remote_port": 3000},
    {"local_port": 5432, "space": "database", "remote_port": 5432},
])

print(f"Applied: {result['applied']}")
print(f"Stopped: {result['stopped']}")
```

### Via API

```shell
curl -X POST https://knot.example.com/space-io/{space_id}/port/apply \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "forwards": [
      {"local_port": 8080, "space": "backend-api", "remote_port": 3000},
      {"local_port": 5432, "space": "database", "remote_port": 5432}
    ]
  }'
```

Response:
```json
{
  "applied": [
    {"local_port": 8080, "space": "backend-api", "remote_port": 3000, "persistent": false}
  ],
  "stopped": [
    {"local_port": 9090, "space": "old-service", "remote_port": 8080, "persistent": false}
  ],
  "errors": []
}
```

Each forward entry supports optional `persistent` and `force` fields (same as individual port forward).

{{< tip >}}
Space-to-space port forwarding only works between spaces in the same zone and owned by the same user. The connection is authenticated and secure.
{{< /tip >}}

---

## Direct Agent-to-Agent Connections {{< pro-badge >}}

In Knot Pro, port-forwarded traffic between spaces on the same host or network can flow **directly** between agents without relaying through the server. This reduces latency and server load.

### How It Works

1. When a port forward is created, the server resolves the target space's direct address and sends it to the source agent.
2. The source agent dials the target agent directly over TCP, authenticating with a user-scoped shared secret (HMAC challenge-response).
3. A single yamux session per peer multiplexes all forwarded connections — one TCP connection carries multiple streams.
4. If the direct connection fails (target restarted, network issue), traffic automatically falls back to server relay.
5. The mode (`direct` or `relay`) is shown in `knot port list` and the UI.

### Environment Variables

The server injects these automatically when launching containers. You do not normally need to set them manually.

| Variable | Default | Purpose |
|---|---|---|
| `KNOT_PEER_PORT` | `12202` | Port the agent listens on inside the container for direct peer connections. Set in the template by the user; the server reads it to know which container port to map. Set to `0` to disable. |
| `KNOT_PEER_EXTERNAL_PORT` | *(set by server)* | The published host port that peers dial. Injected by the server at container launch. Reported to the server at registration. `0` = no direct connections. |

### Enabling Direct Connections

Direct connections are **enabled by default in Knot Pro** for Docker, Podman, and Apple Containers. No configuration is needed — the server allocates a host port, injects the environment variables, and coordinates introductions automatically.

### Disabling Direct Connections

To disable direct peer connections for a specific space, set `KNOT_PEER_PORT=0` in the template's `environment` section:

```yaml
environment:
  - "KNOT_PEER_PORT=0"
```

This tells the agent not to listen for direct connections. All port-forwarded traffic for that space will use the server relay.

To disable peer mesh globally, add to your server configuration:

```toml
[server.peermesh]
enabled = false
```

### Nomad Requirements

For Nomad-launched spaces, the server injects a dynamic port and service registration, but **the template must set `mode = "bridge"` in the network block** for Nomad to create the host→container port mapping:

```hcl
network {
  mode = "bridge"
  port "redis_port" { to = 6379 }
}
```

Without bridge mode, ports are allocated but not reachable from outside the container. Traffic falls back to relay automatically.

### Configuration

The peer mesh port range and behaviour can be tuned in the server configuration:

```toml
[server.peermesh]
enabled = true          # default: true in Pro
port_range_min = 30001  # default: 30001
port_range_max = 32767  # default: 32767
```

### Security

- Direct connections are authenticated with a **user-scoped shared secret** — only spaces owned by the same user can connect directly. Shared spaces (owned by a different user) use relay.
- The secret is derived from the zone encryption key and never sent in cleartext — an HMAC challenge-response proves identity per connection.
- **Note:** data over direct connections flows as cleartext TCP (the HMAC proves identity but does not encrypt). For internet-exposed deployments, keep relay mode (which uses TLS via WebSocket).
