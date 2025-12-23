---
title: Configuration
weight: 20
---

This section covers server configuration options for customizing your **knot** deployment.

---

## Choosing Your Setup

### Single Server (Standalone)

Best for:
- Individual developers
- Small teams (< 10 users)
- Development and testing
- Simple deployments

Use:
- BadgerDB for storage
- Docker or Podman for containers
- No cluster configuration needed

### Cluster Mode

Best for:
- Production deployments
- Distributed teams
- High availability requirements
- Multiple geographic locations

Use:
- BadgerDB, MySQL/MariaDB, or Redis for storage
- Nomad for container orchestration (optional - can use Local Containers)
- Multiple servers with cluster configuration

### Leaf Mode

Best for:
- Remote developers
- Local development with central management
- Bandwidth-constrained locations
- Hybrid deployments

Use:
- Local containers (Docker/Podman)
- Connection to central cluster
- Personal access token

---

## Storage Backend Selection

**BadgerDB**
- Embedded database
- No external dependencies
- Production-ready
- Simple setup
- Works in multi-server clusters (data synced via gossip)

**MySQL/MariaDB**
- External database
- Proven reliability
- Supports large-scale deployments
- Good for existing database infrastructure

**Redis/Valkey**
- In-memory database
- Highest performance
- Requires more memory
- Good for high-traffic deployments

---

## Configuration Topics

### [Storage Systems](storage-systems)
Configure BadgerDB, MySQL/MariaDB, or Redis/Valkey for data storage.

### [Cluster Mode](cluster-mode)
Set up multiple servers for high availability and geographic distribution.

### [Leaf Mode](leaf-mode)
Connect local instances to a central cluster for hybrid deployments.

### [Tunnel Server](tunnel-server)
Expose services to the internet securely through tunnels.

### [Local Containers](local-containers)
Configure Docker, Podman, or Apple Container for local execution.

### [Two Factor Authentication](2fa)
Enable TOTP-based 2FA for enhanced security.

### [User Interface](ui)
Customize the web interface with logos and Gravatar support.

---

## Quick Configuration Examples

### Minimal Standalone

```toml
[server]
listen = "0.0.0.0:3000"
listen_agent = "0.0.0.0:3010"
agent_endpoint = "192.168.1.100:3010"
url = "http://knot.local:3000"
wildcard_domain = "*.knot.local:3000"
encrypt = "<generate with: knot genkey>"

[server.badgerdb]
enabled = true
path = "./badgerdb/"
```

### Production Cluster

```toml
[server]
listen = "0.0.0.0:3000"
listen_agent = "0.0.0.0:3010"
agent_endpoint = "knot1.example.com:3010"
url = "https://knot1.example.com"
wildcard_domain = "*.knot1.example.com"
encrypt = "<generate with: knot genkey>"

[server.mysql]
enabled = true
host = "mysql.example.com"
port = 3306
user = "knot"
password = "<strong-password>"
database = "knot"

[server.cluster]
advertise_addr = "https://knot1.example.com"
key = "<generate with: knot genkey>"
peers = [
  "https://knot1.example.com",
  "https://knot2.example.com",
  "https://knot3.example.com"
]
```

---

## Security Considerations

- Always use HTTPS in production
- Generate strong encryption keys
- Enable 2FA for all users
- Run on private networks or behind VPN
- Regular backups of database
- Keep knot updated

See [Security](../security/) for detailed guidance.
