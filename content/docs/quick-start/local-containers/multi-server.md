---
title: Multi-Server Setup
description: Configure knot to run across multiple servers with Local Containers.
weight: 15
---

Run knot across multiple servers using Docker, Podman, or Apple Containers. No Nomad required.

---

## Overview

Multi-server deployments let you:
- **Scale horizontally** across multiple machines
- **Distribute load** automatically with node selection
- **Achieve high availability** with leaderless clustering
- **Place resources** closer to users (geographic distribution)

---

## Architecture

In a multi-server Local Container deployment:

{{< picture src="../images/multi-server-cluster.svg" alt="Multi-Server Cluster Architecture" >}}

### Key Components

1. **Gossip Protocol**: Servers discover each other and sync data automatically
2. **Local Database**: Each server runs its own database (MySQL, MariaDB, Redis, or BadgerDB)
3. **Data Synchronization**: Cluster data is synced via gossip protocol between servers
4. **Runtime Detection**: Each server reports available container runtimes
5. **Node Selection**: Spaces are automatically assigned to the best available server

---

## Requirements

### Infrastructure

- **2+ servers** (Linux, macOS, or Windows)
- **Container runtime** on each server: Docker, Podman, or Apple Containers
- **Database** on each server: MySQL, MariaDB, Redis/Valkey, or BadgerDB
- **Network connectivity** between all servers

### Software

- knot binary on each server
- Container runtime installed and running

### Database

Each server runs its own database instance. Data is synchronized between servers via gossip protocol.

| Database | Recommended For | Notes |
|----------|----------------|-------|
| **BadgerDB** | Production | Embedded, no external dependency, simple setup |
| **MySQL/MariaDB** | Production | Most reliable, recommended for large clusters |
| **Redis/Valkey** | High performance | In-memory, fastest option |

---

## Setup Guide

### Step 1: Install and Configure Database on Each Server

Each server needs its own database. Install MySQL, MariaDB, Redis, or use BadgerDB (embedded).

#### MySQL/MariaDB Example (run on each server)

```sql
CREATE DATABASE knot;
CREATE USER 'knot'@'localhost' IDENTIFIED BY 'strong-password';
GRANT ALL PRIVILEGES ON knot.* TO 'knot'@'localhost';
FLUSH PRIVILEGES;
```

#### BadgerDB Example (recommended)

No setup needed - BadgerDB is embedded and production-ready. Just enable it in `knot.toml`:

```toml
[server.badgerdb]
enabled = true
path = "./badgerdb/"
```

### Step 2: Generate Cluster Keys

On your first server, generate the encryption keys:

```bash
knot genkey
```

Save the output - you'll use it for all servers.

### Step 3: Configure Server 1 (Primary)

Create `knot.toml` on the first server:

```toml {filename="knot.toml"}
[server]
listen = "0.0.0.0:3000"
listen_agent = "0.0.0.0:3010"
# Update this to the public IP/DNS of this server
agent_endpoint = "server1.example.com:3010"
url = "https://server1.example.com"
wildcard_domain = "*.server1.example.com"
encrypt = "<output from knot genkey>"

# Zone for this server (optional)
zone = "us-west"

[server.terminal]
webgl = true

# Local database (each server has its own)
[server.badgerdb]
enabled = true
path = "./badgerdb/"

# Docker configuration
[server.docker]
host = "unix:///var/run/docker.sock"

# Cluster configuration
[server.cluster]
# This server's address
advertise_addr = "https://server1.example.com"
# Shared cluster key
key = "<output from knot genkey>"
# List of all servers in the cluster
peers = [
  "https://server1.example.com",
  "https://server2.example.com",
  "https://server3.example.com"
]
```

### Step 4: Configure Additional Servers

Create `knot.toml` on each additional server. Only a few settings change:

**Server 2 (`knot.toml`):**

```toml
[server]
listen = "0.0.0.0:3000"
listen_agent = "0.0.0.0:3010"
# Different for each server
agent_endpoint = "server2.example.com:3010"
url = "https://server2.example.com"
wildcard_domain = "*.server2.example.com"
encrypt = "<SAME as server1>"

# Different zone (optional)
zone = "us-east"

# Local database on this server
[server.badgerdb]
enabled = true
path = "./badgerdb/"

# Podman on this server
[server.podman]
host = "unix:///var/run/podman.sock"

[server.cluster]
# Different for each server
advertise_addr = "https://server2.example.com"
# Same key as server1
key = "<SAME as server1>"
# Same peer list
peers = [
  "https://server1.example.com",
  "https://server2.example.com",
  "https://server3.example.com"
]
```

**Server 3 (`knot.toml`):**

```toml
[server]
listen = "0.0.0.0:3000"
listen_agent = "0.0.0.0:3010"
agent_endpoint = "server3.example.com:3010"
url = "https://server3.example.com"
wildcard_domain = "*.server3.example.com"
encrypt = "<SAME as server1>"

zone = "eu-central"

# Local database on this server
[server.badgerdb]
enabled = true
path = "./badgerdb/"

[server.docker]
host = "unix:///var/run/docker.sock"

[server.cluster]
advertise_addr = "https://server3.example.com"
key = "<SAME as server1>"
peers = [
  "https://server1.example.com",
  "https://server2.example.com",
  "https://server3.example.com"
]
```

### Step 5: Start All Servers

Start the knot server on each machine:

```bash
knot server --config knot.toml
```

Servers will:
1. Initialize their local database
2. Discover each other via gossip protocol
3. Sync cluster data automatically
4. Report available container runtimes
5. Begin accepting space deployments

### Step 6: Verify Cluster Formation

Check logs on each server. You should see messages like:

```
[INFO] Cluster member joined: server2.example.com
[INFO] Cluster member joined: server3.example.com
[INFO] Detected runtime: docker
[INFO] Cluster ready: 3 members
```

---

## Using Zones

Zones let you group servers geographically or logically. Spaces can then be assigned to specific servers within zones and traffic load balanced over the members of the zone.

Servers within the same zone can share access to local containers, allowing spaces to be accessed from any server in the zone. However, containers do not automatically migrate to another server if one fails; manual intervention or external orchestration is required for failover.

Note: For Nomad-based deployments, servers in the same zone provide high availability through Nomad's built-in failover mechanisms.

### Configure Zones

Add a `zone` setting to each server's `knot.toml`:

```toml
[server]
zone = "us-west"  # or "us-east", "eu-central", etc.
```

See [Node Selection](node-selection/) for details on assigning spaces to zones.

---

## Accessing Spaces

Users access spaces through the load balancer or any server's URL.

### Option 1: Load Balancer (Recommended)

Place a load balancer in front of all servers:

{{< picture src="../images/multi-server-load-balancer.svg" alt="Load Balancer Setup" >}}

The load balancer can use any strategy (round-robin, least connections, etc.).

### Option 2: Direct Server Access

Users can access any server directly. If the space is on a different server, they'll be redirected automatically.

---

## Testing the Setup

### 1. Create a Template

Create a simple template that uses Local Containers:

```yaml {filename="test-template.yaml"}
name: test-space
container:
  image: ubuntu:latest
  command: sleep infinity
```

### 2. Create a Space

Create a space without specifying a server - knot will auto-select:

```bash
knot space create test-space --template test-template
```

### 3. Verify Node Selection

Check which server the space was deployed to:

```bash
knot space get test-space
```

Look for the `server` or `node` field in the output.

### 4. Test Manual Selection

Create a space on a specific server:

```bash
knot space create test-space-2 --template test-template --server server2.example.com
```

---

## Troubleshooting

### Servers Not Discovering Each Other

**Problem**: Servers don't see each other in the cluster.

**Solutions**:
- Verify `peers` list matches on all servers
- Check `advertise_addr` is accessible from other servers
- Ensure firewall allows gossip traffic (default port 3010)
- Verify all servers use the same `cluster.key`

### Spaces Not Distributing

**Problem**: All spaces go to one server.

**Solutions**:
- Verify all servers are in the cluster (check logs for "Cluster member joined")
- Verify runtime detection: check logs for `Detected runtime` messages
- Ensure templates don't have server constraints
- Review node selection settings

### Database Connection Issues

**Problem**: Server can't connect to its local database.

**Solutions**:
- Verify the database is running on the local server
- Check database credentials in `knot.toml`
- For MySQL/PostgreSQL: test connection with `mysql -u knot -p` or `psql -U knot`
- For BadgerDB: check file permissions on the badgerdb directory
- Check logs for specific database error messages

---

## Best Practices

1. **Use BadgerDB by Default**: Production-ready embedded database with no external dependencies
2. **Use MySQL/MariaDB for Large Clusters**: If you have existing database infrastructure or very large deployments
3. **Monitor Server Health**: Set up monitoring for each server
4. **Regular Backups**: Backup each server's database regularly
5. **Use Zones**: Organize servers logically or geographically
6. **Test Failover**: Simulate server failure to verify automatic recovery
7. **Document Architecture**: Keep a diagram of your deployment

---

## Next Steps

- [Node Selection](node-selection/) - Learn how spaces are assigned to servers
- [Configuration](../../configuration/) - Detailed configuration options
- [Cluster Architecture](../../reference/architecture/cluster-architecture/) - Deep dive on clustering
- [Troubleshooting](../../troubleshooting/) - Common issues and solutions
