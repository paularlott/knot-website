---
title: Agent Commands
description: Control a running space from inside it with knot agent commands - lifecycle, events, jobs, ports, and more.
type: Guide
tags: [spaces, scripting]
weight: 150
---

The `knot agent` CLI runs inside a space and talks to the local agent. This page is an overview of every command group; each feature page linked below covers its commands in depth.

| Command | Description |
|---|---|
| `knot agent space shutdown` | Request an immediate shutdown of the space. |
| `knot agent space restart` | Request a stop and restart of the space. |
| `knot agent space set-note --note "…"` | Set the space's short description — see [Notes](../notes/). |
| `knot agent space get-field / set-field` | Read and write custom fields of the space. |
| `knot agent wait-for-start [--timeout 300]` | Block until the space has fully started. |
| `knot agent event --type … --name … --payload …` | Emit an event to configured event sinks — see [Event Sinks](../log-sinks/). |
| `knot agent jobs list / run` | List and trigger scheduled jobs — see [Jobs](../jobs/). |
| `knot agent methods register / unregister` | Register space methods — see [Methods](../methods/). |
| `knot agent port forward / list / stop` | Space-to-space port forwarding — see [Space-to-Space Port Forwarding](../space-space-port-forwarding/). |
| `knot agent run-script` | Run a script inside the space — see [Provisioning](../provisioning/). |
| `knot agent skills list / show / update / delete` | Manage in-space skills — see [Skills](../../ai/skills/). |
| `knot agent connect list / delete` | List and remove client connections to the space. |
| `knot agent tunnel …` | Create and manage agent tunnels — see [Agent Tunnels](../../tunnels/agent-tunnels/). |

---

### `shutdown` Command

The `shutdown` command allows the space to request an immediate shutdown. To execute this command, run:

```shell
knot agent space shutdown
```

---

### `restart` Command

The `restart` command allows the space to request a restart. To execute this command, run:

```shell
knot agent space restart
```

---

### `wait-for-start` Command

Scripts that run early in a space's lifecycle can wait until every service has started:

```shell
knot agent wait-for-start --timeout 120
```

The command exits `0` once the space reports started, or non-zero if the timeout is reached.
