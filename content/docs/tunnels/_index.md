---
title: Tunnels
description: Expose local or in-space HTTP and HTTPS services on the internet via a knot server.
type: Overview
tags: [networking]
weight: 100
---

**knot** tunnels allow HTTP and HTTPS services running on a local workstation or within a space to be exposed on the internet via a **knot** server.

---

## Configuring the Server

Before tunnels can be used, the **knot** server must be configured to allow tunneling. This is done by setting the `listen_tunnel` option in the server configuration:

```toml
[server]
listen_tunnel = 0.0.0.0:3001
tunnel_domain = "*.knot-tunnel.internal:3001"
```

- The `listen_tunnel` option specifies the address and port that the **knot** server will listen on for internet traffic to forward to user tunnels.
- A wildcard domain must be pointed to this address and port, e.g., `*.tunnel.knot.internal`.

### Domain Routing

The leftmost component of the host determines the username and tunnel name. For example:
- `example-tunnel1.tunnel.knot.internal` routes traffic to the tunnel named `tunnel1` for the user `example`.

---

## Creating a Tunnel

Tunnels can be created either on a local machine (desktop) or within a space
(managed by the knot agent).

- **Desktop tunnels** (described below) run as a foreground process on your
  local machine and live for the life of that command.
- **Agent tunnels**, started inside a space, can optionally be handed to the
  knot agent so they keep running after the launching command exits. See
  [Agent Tunnels](./agent-tunnels/) for `--daemon`, `stop`, and `list`.

---

### Creating a Tunnel on a Local Machine

1. **Connect to the Knot Server**
   Open a terminal and connect to the **knot** server by running the following command (replace the URL with the actual server address):

   ```shell
   knot connect https://knot.internal:3000
   ```

   - The `connect` command only needs to be run once or if the login expires.

2. **Create a Tunnel**
   Run the `tunnel` command with the protocol, port, and tunnel name:

   ```shell
   knot tunnel http 8080 test1
   ```

   - This creates a tunnel to the local port `8080` with the tunnel name `example-test1.tunnels.knot.internal`.
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
list` to manage it. See [Agent Tunnels](./agent-tunnels/) for the full
agent-managed workflow.
