---
title: Proxied Connections
weight: 40
---

## Overview

If the [knot client](/docs/getting-started/client/) is installed and the knot server is started with the option `--enable-proxy` then it provides functionality to allow connections to services running within a Nomad cluster to be proxied via knot, this can allow connection to services without the local machine having direct access to the cluster network.

## Lookup

The lookup command queries for the IP and port associated with a service.

```bash
knot proxy lookup example.service.consul
```

## Port Forwarding

Port forwarding will forward a local port to the port associated with the service running within the Nomad cluster.

```bash
knot proxy port :9000 example.service.consul
```

The browser can then be pointed at `http://localhost:9000`

## SSH Forwarding

SSH forwarding will forward a SSH connection to a SSH server running within the Nomad cluster identified by the service name.

```bash
ssh -o ProxyCommand='knot proxy ssh %h' -o StrictHostKeyChecking=no user@mytest.service.consul
```
