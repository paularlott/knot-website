---
title: Network Architecture
weight: 30
---

Network configuration and communication patterns.

---

## Ports

**3000**: Web interface and API (configurable)

**3010**: Agent connections (configurable)

**3001**: Tunnel server (optional, configurable)

**3053**: DNS server (optional, configurable)

---

## Communication

**Client to Server**: HTTPS for web interface and API

**Agent to Server**: Persistent connection for commands and data

**Server to Database**: Database-specific protocol

**Server to Server**: Gossip protocol for data synchronization

---

## Security

- All connections should use TLS
- Run on private networks
- Use VPN for remote access
- Firewall rules to restrict access
- Only expose tunnel port publicly (if needed)
