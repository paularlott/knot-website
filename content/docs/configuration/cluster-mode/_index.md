---
title: Cluster Mode
description: Configure knot servers in a leaderless cluster using the gossip protocol.
type: Overview
tags: [deployment, configuration]
weight: 20
---

The Knot server supports a **leaderless cluster mode** built on the gossip protocol. This mode can operate within the same location/datacenter or across multiple geographic regions, providing flexibility and scalability.

Cluster mode allows Knot servers to be placed close to developers, minimizing latency and maximizing performance. Users and templates can be managed seamlessly from any location.

Cluster mode supports communication over both `https` and `TCP / UDP` connections. While `TCP / UDP` is the preferred method for its performance and reliability, `https` can be used when direct connections are unavailable.

Mesh networks like [Netbird](https://netbird.io) or [Tailscale](https://tailscale.com) can help establish secure worldwide connections between servers.

---

## Enabling Cluster Mode

To enable cluster mode, configure the `server.zone` option in the `knot.toml` file for each server. The `zone` setting identifies the location of each Knot server. For example, servers in Australia could use `zone = "au"`, while servers in the United Kingdom could use `zone = "gb"`. There are no restrictions on naming.

{{< tip "warning" >}}
All servers must be using either `https` or `TCP / UDP` for communication, at this time it's not possible to mix transports within the same cluster.
{{< /tip >}}

---

### Configuring with HTTPS

In this mode, Knot servers communicate over `https`. All servers must be able to reach each other. Temporary network failures are handled gracefully, and depending on the number of servers in the cluster, data may be routed around the failure. If not, servers will catch up on missing data once connectivity is restored.

To enable cluster mode over `https`, add the following configuration to your `knot.toml` file and adjust as needed:

```toml {{filename="knot.toml"}}
[server]
zone = 'au'

[server.cluster]
advertise_addr = 'https://knot1.internal/'
key = 'NDJuIFxrRbWLp6tKhVzyqNs5H5fCK1Cl'
peers = ['https://knot1.internal', 'https://knot2.internal', 'https://knot3.internal']
```

#### Configuration Parameters

- **`advertise_addr`**: The address this server advertises to the cluster. Other servers will use this address to connect.
- **`key`**: A key used to authenticate nodes within the cluster. Generate it using `knot genkey`.
- **`peers`**: A list of known servers. These should be the most stable servers, as they are used by nodes during startup to find existing cluster members. Once a server joins the cluster, it discovers other members dynamically. If all connections are lost, the server will retry the peers listed here.

{{< tip >}}
Use this mode only when `TCP / UDP` connections between Knot servers are unavailable.
{{< /tip >}}

---

### Configuring with TCP / UDP

In this mode, Knot servers communicate over `TCP` or `UDP`. The protocol is chosen dynamically for each message to balance performance and reliability. As with `https` mode, temporary network failures are handled gracefully, and servers will catch up on missing data once connectivity is restored.

To enable cluster mode over `TCP / UDP`, add the following configuration to your `knot.toml` file and adjust as needed:

```toml {{filename="knot.toml"}}
[server]
zone = 'au'

[server.cluster]
advertise_addr = 'knot1.internal:3100'
bind_addr = '0.0.0.0:3100'
key = 'NDJuIFxrRbWLp6tKhVzyqNs5H5fCK1Cl'
peers = ['knot1.internal:3100', 'knot2.internal:3100', 'knot3.internal:3100']
compression = true
```

#### Configuration Parameters

- **`advertise_addr`**: The address this server advertises to the cluster. Other servers will use this address to connect.
- **`bind_addr`**: The address and port this server binds to for cluster communication.
- **`key`**: A key used to encrypt data between cluster members. Generate it using `knot genkey`.

Every member of a zone must also be configured with the **same `encrypt` key** (`server.encrypt`, generated with `knot genkey`): it derives agent registration keys, agent tokens and the zone's agent TLS certificate. knot refuses to start without it.
- **`peers`**: A list of known servers. These should be the most stable servers, as they are used by nodes during startup to find existing cluster members. Once a server joins the cluster, it discovers other members dynamically. If all connections are lost, the server will retry the peers listed here.
- **`compression`**: Enables or disables data compression for communication between cluster members. Compression is enabled by default and should work in most cases.
- **`tcp_only`**: Use `TCP` only for cluster communication — for environments where `UDP` is unavailable.
- **`min_cluster_size`**: Leader-election quorum floor: the fewest nodes that must be visible before a zone leader can be elected or kept. Set it to the majority of the smallest zone you will run — `2` for two- or three-server production zones. The default of `1` suits single-machine testing, where a lone server must elect itself.

---

## Viewing Cluster Health

When Knot is running in cluster mode, a new menu item, `Cluster Info`, becomes available for admin users and those with the appropriate permissions. This menu displays a table of all servers in the cluster, including their zones and other relevant information.

{{< zoom-picture src="images/cluster-info.webp" caption="Cluster Information" >}}
