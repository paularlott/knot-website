---
title: Agent Commands
description: Control a running space from inside it with knot agent commands - lifecycle, events, jobs, ports, and more.
type: Guide
tags: [spaces, scripting]
weight: 150
---

Inside a space, the `knot` command is the knot agent binary, which talks to the local agent. Lifecycle commands live under `knot agent`; the other command groups are top-level. This page is an overview of every command; each feature page linked below covers its commands in depth, and the [knot agent CLI reference](/reference/cli/agent/) lists every option.

| Command | Description |
|---|---|
| `knot agent shutdown` | Request an immediate shutdown of the space. |
| `knot agent restart` | Request a stop and restart of the space. |
| `knot agent set-note "<note>"` | Set the space's short description — see [Notes](../notes/). |
| `knot agent get-field <name>` / `set-field <name> <value>` | Read and write custom fields of the space. |
| `knot agent wait-for-start [--timeout 60]` | Block until the agent is running and accepting commands. |
| `knot event <type> [payload]` | Emit a custom event to configured event sinks — see [Events](/reference/events/). |
| `knot jobs list / run` | List and trigger the space's jobs — see [Jobs](../jobs/). |
| `knot methods register / unregister` | Register space methods — see [Methods](../methods/). |
| `knot port forward / list / stop / throttle` | Space-to-space port forwarding — see [Space-to-Space Port Forwarding](../space-space-port-forwarding/). |
| `knot run-script` | Run a script inside the space — see [Provisioning](../provisioning/). |
| `knot tunnel http / https / list / stop` | Create and manage agent tunnels — see [Agent Tunnels](../../tunnels/agent-tunnels/). |
| `knot file …` | Work with file storage buckets as the space's owner — see [File Storage](/docs/file-storage/). |
| `knot mcp` | Serve the knot MCP server over stdio through the agent — see [`knot mcp`](/reference/cli/agent/#knot-mcp). |

---

### `shutdown` Command

The `shutdown` command allows the space to request an immediate shutdown. To execute this command, run:

```shell
knot agent shutdown
```

---

### `restart` Command

The `restart` command allows the space to request a restart. To execute this command, run:

```shell
knot agent restart
```

---

### `wait-for-start` Command

Scripts that run early in a space's lifecycle can wait until the agent is ready:

```shell
knot agent wait-for-start --timeout 120
```

The command exits `0` once the agent is running and accepting commands, or non-zero if the timeout (default 60 seconds) is reached.
