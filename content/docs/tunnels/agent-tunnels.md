---
title: Agent Tunnels
description: Agent-owned tunnels inside a space keep running after the launching command exits.
type: Guide
tags: [networking]
weight: 101
---

When a tunnel is started **inside a space**, the knot agent can own it for you so
it keeps running even after the command that launched it exits. This is distinct
from [desktop tunnels](./), which run as a foreground process on your local
machine for the life of that command.

Agent-owned tunnels live for the **lifetime of the knot agent** — they are not
persisted, so they stop if the space (and therefore the agent) is stopped or
restarted.

You can manage them either **inside the space** (`knot tunnel ...`) or
**remotely from the desktop** (`knot space tunnel ...`). Both operate on the same
agent-owned registry, so a tunnel started one way is visible to the other.

---

## Prerequisites

- The knot server must be [configured for tunnels](./#configuring-the-server).
- **Inside a space:** run `knot tunnel ...` in a terminal in the space. The
  `--daemon`, `stop`, and `list` subcommands require the knot agent.
- **From the desktop:** run `knot space tunnel ...` (the space must be running).
  This drives the space's agent remotely via the knot server.

---

## Starting a Tunnel

### Foreground (default)

```shell
knot tunnel http 8080 test1
```

This opens an HTTP tunnel exposing local port `8080` as
`<user>--test1.<tunnel_domain>`. The tunnel stays active until you press
`Ctrl-C` (or the process is killed), exactly as before.

By default the tunnel is created on the server that owns the space. A
foreground tunnel can instead be created on any other knot server — see
[Targeting Another Knot Server](#targeting-another-knot-server).

Use `https` instead of `http` for an HTTPS tunnel:

```shell
knot tunnel https 8443 secure1
```

### Daemon mode

Add `--daemon` to hand the tunnel to the knot agent and return immediately:

```shell
knot tunnel http 8080 test1 --daemon
```

- The command prints the tunnel URL and exits.
- The tunnel is owned by the agent and runs until the agent exits, or until you
  stop it explicitly.
- The agent uses its own server credentials, so no `--server` / `--token` flags
  are needed (or used) in daemon mode — daemon tunnels always run on the server
  that owns the space, and combining `--daemon` with `--server` / `--token` or a
  configured `--alias` is an error (see below).

---

## Targeting Another Knot Server

A foreground tunnel (no `--daemon`) can be created on **any** knot server this
space can reach, not just the one that owns the space. Pass the target server
and an API token valid on it:

```shell
knot tunnel http 8080 test1 --server https://other.knot.internal --token <api-token>
```

Or use an alias configured in the space's config file (`knot.toml` in the
current directory, `~/knot.toml`, or `~/.config/knot/knot.toml`) using the same
layout `knot connect` writes on the desktop:

```toml
[client.connection.other]
server = "https://other.knot.internal"
token = "<api-token>"
```

```shell
knot tunnel http 8080 test1 -a other
```

Notes:

- The tunnel runs in this process and stops when it exits, like any foreground
  tunnel — it is not handed to the agent.
- The tunnel address is built from **your username on the target server**, and
  the tunnel counts against that server's tunnel quota and permissions.
- `--daemon` cannot be combined with `--server` / `--token` or a configured
  `--alias`: the agent creates daemon tunnels only on the space's own server.
- Without `--server` / `--token` / `--alias` the tunnel is created on the
  server that owns the space, as before.
- The space must be able to reach the target server over the network.

---

## Stopping a Tunnel

Stop a daemon-owned tunnel by its name:

```shell
knot tunnel stop test1
```

This only affects tunnels owned by the agent. A foreground tunnel started
without `--daemon` is stopped by exiting that process (e.g. `Ctrl-C`).

---

## Listing Tunnels

List all tunnels currently owned by the agent:

```shell
knot tunnel list
```

Example output:

```shell
Active tunnels:
  test1  8080  http  https://alice--test1.tunnels.knot.internal
```

---

## Remote Management

You can also manage a space's agent-owned tunnels from the desktop with
`knot space tunnel`, without opening a terminal in the space. These commands
drive the same agent-owned registry through the knot server, so a tunnel started
from the desktop appears in `knot tunnel list` inside the space, and vice versa.
The space must be running.

### Starting a tunnel

```shell
knot space tunnel http myspace 8080 test1
```

Daemon mode is implied — the command prints the tunnel URL and exits, and the
tunnel is owned by the space's agent. `https` is also supported.

### Listing tunnels

```shell
knot space tunnel list myspace
```

### Stopping a tunnel

```shell
knot space tunnel stop myspace test1
```

---

## Scripting

Agent-owned tunnels can be managed from scripts via `knot.space`, which is
available in all scriptling environments (startup scripts, MCP tools, and
standalone scripts). The space must be running.

```python
import knot.space as space

# Start a tunnel — returns the public URL
url = space.tunnel_start("myspace", "http", 8080, "myapp")
print(url)

# List active tunnels
for t in space.tunnel_list("myspace"):
    print(t["name"], t["url"])

# Stop a tunnel by name
space.tunnel_stop("myspace", "myapp")
```

These call the same server API as the `knot space tunnel` CLI commands, so a
tunnel started from a script is visible to `knot tunnel list` inside the space.

---

## Behaviour Notes

- **Not persistent:** agent-owned tunnels are not stored anywhere. If the space
  is stopped or restarted, all daemon tunnels are removed and must be started
  again.
- **One tunnel per name:** starting a daemon tunnel with a name that already
  has one is rejected. Use `knot tunnel stop <name>` first.
- **Identity:** the tunnel name is combined with the space owner's username to
  form `<user>--<name>.<domain>`, just like desktop tunnels.
