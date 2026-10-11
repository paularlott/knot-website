---
description: knot's network configuration — ports, client/agent/server communication paths, and TLS/VPN hardening guidance.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/architecture/network/
sources:
    - resource: https://getknot.dev/reference/architecture/network/
status: stable
tags:
    - architecture
    - networking
title: Network Architecture
type: Reference
---
# Network Architecture

Network configuration and communication patterns.

---

## Ports

**3000**: Web interface and API (configurable)

**3010**: Agent connections (configurable)

**3001**: Tunnel server (optional, configurable)

**3053**: DNS server (optional, configurable)

**Cluster port**: Gossip between servers over TCP / UDP, set with `server.cluster.bind_addr` and `server.cluster.advertise_addr` (`--cluster-bind-addr`, `--cluster-advertise-addr`), for example `3100`. In `https` mode the cluster uses the web port instead. See [Cluster Mode](../../knot-docs/configuration/cluster-mode.md).

**S3** : With file storage enabled, the S3 endpoint is served at `/s3` on the web port, so it needs no port of its own.

---

## Communication

**Client to Server**: HTTPS for web interface and API

**Agent to Server**: Persistent connection for commands and data

**Server to Database**: Database-specific protocol

**Server to Server**: Gossip protocol for data synchronization

**File content between servers**: With file storage, servers stream file content they are missing directly from a peer over the cluster transport, secured like the rest of the cluster traffic (the cluster key on the gossip port, or TLS when `advertise_addr` is an `https://` URL); no extra port is needed

---

## Security

- All connections should use TLS
- Run on private networks
- Use VPN for remote access
- Firewall rules to restrict access
- Only expose tunnel port publicly (if needed)
