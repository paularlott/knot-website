---
title: Direct Connection
weight: 30
---

## Overview

If the [knot client](/docs/getting-started/client/) is installed then it provides functionality to allow connection to services running within a Nomad cluster using the service names.

All subcommands can accept the `--nameserver` parameter, if given then the specified nameserver will be queried for the service name.

## Lookup

The lookup command queries for the IP and port associated with a service.

```bash
knot direct lookup example.service.consul
```

## Port Forwarding

Port forwarding will forward a local port to the port associated with the service running within the Nomad cluster.

```bash
knot direct port :9000 example.service.consul
```

The browser can then be pointed at `http://localhost:9000`

## SSH Forwarding

SSH forwarding will forward a SSH connection to a SSH server running within the Nomad cluster identified by the service name.

```bash
ssh -o ProxyCommand='knot direct ssh %h' -o StrictHostKeyChecking=no user@mytest.service.consul
```
