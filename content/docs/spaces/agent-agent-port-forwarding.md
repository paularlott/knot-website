---
title: Agent-to-Agent Port Forwarding
weight: 125
---

Agent-to-agent port forwarding allows spaces to communicate directly with each other. This is useful for microservices architectures where one space needs to access a service running in another space (for example, a frontend space connecting to a backend API space).

---

## Requirements

For agent-to-agent port forwarding to work:
- Both spaces must be running and have active agents
- Spaces must be in the same zone
- Spaces must be owned by the same user
- Local port must be in the range 1-65535

## Commands

The following commands are run from inside a space using the knot agent:

### Forward Port

Forward a port from the current space to another space:

```shell
knot port forward <local-port> <space-name> <remote-port>
```

Example:
```shell
knot port forward 8080 backend-api 3000
```

This forwards port 8080 in the current space to port 3000 in the `backend-api` space.

### List Active Forwards

View all active port forwards from the current space:

```shell
knot port list
```

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

## Desktop Client Commands

The following commands are run from your desktop machine using the knot CLI:

### Forward Port

Forward a port from one space to another space:

```shell
knot port forward <from-space> <from-port> <to-space> <to-port>
```

Example:
```shell
knot port forward frontend 8080 backend-api 3000
```

This forwards port 8080 in the `frontend` space to port 3000 in the `backend-api` space.

### List Active Forwards

View all active port forwards from a specific space:

```shell
knot port list <space-name>
```

Example:
```shell
knot port list frontend
```

### Stop Port Forward

Stop an active port forward in a specific space:

```shell
knot port stop <space-name> <local-port>
```

Example:
```shell
knot port stop frontend 8080
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
Agent-to-agent port forwarding only works between spaces in the same zone and owned by the same user. The connection is authenticated and secure.
{{< /tip >}}
