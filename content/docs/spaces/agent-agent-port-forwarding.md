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

{{< tip >}}
Agent-to-agent port forwarding only works between spaces in the same zone and owned by the same user. The connection is authenticated and secure.
{{< /tip >}}
