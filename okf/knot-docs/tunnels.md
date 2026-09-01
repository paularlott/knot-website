---
description: Expose local or in-space HTTP and HTTPS services on the internet via a knot server.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/tunnels/
sources:
    - resource: https://getknot.dev/docs/tunnels/
status: stable
tags:
    - networking
title: Tunnels
type: Overview
---
# Tunnels

Knot tunnels allow HTTP and HTTPS services running on a local workstation or within a space to be exposed on the internet via a Knot server.

---

## Configuring the Server

Tunnels require the server's tunnel listener to be configured — see [Tunnel Server Configuration](configuration/tunnel-server.md) for the `listen_tunnel` and `tunnel_domain` settings and their DNS requirements.

Tunnel addresses are built as `<user>--<tunnel name>.<tunnel domain>`, for example `example--tunnel1.tunnel.knot.internal`.

---

## Creating a Tunnel

Tunnels can be created either on a local machine (desktop) or within a space
(managed by the knot agent).

- **Desktop tunnels** (described below) run as a foreground process on your
  local machine and live for the life of that command.
- **Agent tunnels**, started inside a space, can optionally be handed to the
  knot agent so they keep running after the launching command exits. See
  [Agent Tunnels](tunnels/agent-tunnels.md) for `--daemon`, `stop`, and `list`.

---

### Creating a Tunnel on a Local Machine

1. **Connect to the Knot Server**
   Open a terminal and connect to the Knot server by running the following command (replace the URL with the actual server address):

   ```shell
   knot connect https://knot.internal:3000
   ```

   - The `connect` command only needs to be run once or if the login expires.

2. **Create a Tunnel**
   Run the `tunnel` command with the protocol, port, and tunnel name:

   ```shell
   knot tunnel http 8080 test1
   ```

   - This creates a tunnel to the local port `8080` with the address `example--test1.tunnel.knot.internal`.
   - Stopping the `knot tunnel` command will stop and remove the tunnel.

---

### Creating a Tunnel in a Space

Run the same command from a terminal **inside a space**:

```shell
knot tunnel http 8080 test1
```

By default this behaves like the desktop version — the tunnel lives for the life
of the command. To let the knot agent own the tunnel so it keeps running after
the command exits, add `--daemon`, and use `knot tunnel stop` / `knot tunnel
list` to manage it. See [Agent Tunnels](tunnels/agent-tunnels.md) for the full
agent-managed workflow.
