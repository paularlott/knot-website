---
title: Tunnels
weight: 10
---

Knot Tunnels allow local http and https services to be exposed on the internet via a knot server.

## Configuring the Server

Before tunnels can be used the knot server must be configured to allow tunneling, to do this the `listen_tunnel` option must be set in the server configuration:

```yaml
server:
  listen_tunnel: 0.0.0.0:3001
```

The `listen_tunnel` option specifies the address and port that the knot server will listen on for internet traffic to forward to the user tunnels.

A wildcard domain must be pointed to this address and port e.g. `*.tunnel.example.com`. The left most component of the host is the username and tunnel name e.g. `example-tunnel1.tunnel.example.com` the traffic is routed to `tunnel1` for the user `example`.

## Creating a Tunnel

Tunnels can be used within spaces or on a local machine.

### Creating a Tunnel on a Local Machine

On the client machine connect to the knot server, replacing the URL with the address of the real server, first open a terminal and run:

```shell
knot connect https://knot.example.com
```

The connect command only needs to be run once or if the login expires.

Next to create a tunnel by running the `tunnel` command with the protocol, port and tunnel name:

```shell
knot tunnel http 8080 test1
```

This will create a tunnel to the local port 8080 and the tunnel name `example-test1.tunnels.example.com`.

Stopping `knot tunnel` stops and removes the tunnel.

### Creating a Tunnel in a Space

Enter the space via a terminal and connect to the knot server, replacing the URL with the address of the real server:

```shell
knot-agent connect https://knot.example.com
```

The connect command only needs to be run once or if the login expires.

Next to create a tunnel by running the `tunnel` command with the protocol, port and tunnel name:

```shell
knot tunnel http 8080 test1
```

This will create a tunnel to the local port 8080 and the tunnel name `example-test1.tunnels.example.com`.

Stopping `knot tunnel` stops and removes the tunnel.
