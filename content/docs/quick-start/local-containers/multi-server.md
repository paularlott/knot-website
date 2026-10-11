---
title: Multi-Server Setup
description: Configure knot to run across multiple servers with Local Containers.
type: Guide
tags: [deployment]
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

{{< mermaid >}}
flowchart TD
  subgraph S1["Server 1 (Primary)"]
    R1["Docker"]
    DB1[("MySQL")]
  end
  subgraph S2["Server 2 (Secondary)"]
    R2["Podman"]
    DB2[("MySQL")]
  end
  subgraph S3["Server 3 (Secondary)"]
    R3["Apple"]
    DB3[("MySQL")]
  end
  Gossip(("Gossip Protocol\nCluster Sync"))
  S1 <-.-> Gossip
  S2 <-.-> Gossip
  S3 <-.-> Gossip
{{< /mermaid >}}

### Key Components

1. **Gossip Protocol**: Servers discover each other and sync data automatically
2. **Local Database**: Each server runs its own database (MySQL, MariaDB, PostgreSQL, Redis, or BadgerDB)
3. **Data Synchronization**: Cluster data is synced via gossip protocol between servers
4. **Runtime Detection**: Each server reports available container runtimes
5. **Node Selection**: Spaces are automatically assigned to the best available server

---

## Requirements

### Infrastructure

- **2+ servers** (Linux, macOS, or Windows)
- **Container runtime** on each server: Docker, Podman, or Apple Containers
- **Database** on each server: MySQL, MariaDB, PostgreSQL, Redis/Valkey, or BadgerDB
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
| **PostgreSQL** | Production | For sites already running PostgreSQL |
| **Redis/Valkey** | High performance | In-memory, fastest option |

---

## Setup Guide

### Step 1: Install and Configure Database on Each Server

Each server needs its own database. Install MySQL, MariaDB, PostgreSQL, Redis, or use BadgerDB (embedded).

#### MySQL/MariaDB Example (run on each server)

```sql
CREATE DATABASE knot;
CREATE USER 'knot'@'localhost' IDENTIFIED BY 'strong-password';
GRANT ALL PRIVILEGES ON knot.* TO 'knot'@'localhost';
FLUSH PRIVILEGES;
```

#### PostgreSQL Example (run on each server)

```sql
CREATE USER knot WITH PASSWORD 'strong-password';
CREATE DATABASE knot OWNER knot;
```

Then enable it in `knot.toml` in place of the `[server.badgerdb]` section used below:

```toml
[server.postgres]
enabled = true
host = "localhost"
port = 5432
user = "knot"
password = "strong-password"
database = "knot"
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

Check the logs on each server for `enabling cluster mode on` (with the server's `advertiseAddr`), `starting gossip cluster` and `full state sync complete`.

Then sign in to any server and open **Admin** → **Cluster Info**: every server should be listed. The page needs the Cluster Info permission and is only shown when `advertise_addr` is set.

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

See [Node Selection](/docs/configuration/node-selection/) for details on assigning spaces to zones.

---

## Accessing Spaces

Users access spaces through the load balancer or any server's URL.

### Option 1: Load Balancer (Recommended)

Place a load balancer in front of all servers:

{{< mermaid >}}
flowchart TD
  LB["Load Balancer\nknot.example"]
  LB --> S1["Server 1"]
  LB --> S2["Server 2"]
  LB --> S3["Server 3"]
{{< /mermaid >}}

The load balancer can use any strategy (round-robin, least connections, etc.).

### Option 2: Direct Server Access

Users can access any server directly. If a space runs on a different server, the server they are using forwards the request to it, so there is no redirect and nothing extra to configure.

---

## Testing the Setup

### 1. Create a Template

Create a template named `test-template` with the platform set to `Local Container`, as in [Creating a Template](../creating-a-template/). A Local Container template can run on any server, whichever container runtime it has.

### 2. Create a Space

Create a space from the template — knot picks the server automatically:

```bash
knot space create test-space test-template
knot space start test-space
```

### 3. Verify Node Selection

Check which server the space was deployed to: on the **Spaces** page, the host running the space is shown under its name (`Host: …`).

### 4. Test Manual Selection

To put a space on a specific server, create it from the web interface: click `More options` on the create form and pick the server in the **Node** list (shown when more than one node can run the template). Leave it on auto-select to let knot choose the node with the least load.

---

## Troubleshooting

### Servers Not Discovering Each Other

**Problem**: Servers don't see each other in the cluster.

**Solutions**:
- Verify `peers` list matches on all servers
- Check `advertise_addr` is accessible from other servers
- Ensure the firewall lets each server reach the others' `advertise_addr` (with an `https://` address, cluster traffic uses the server's web port at `/cluster`)
- Verify all servers use the same `cluster.key`

### Spaces Not Distributing

**Problem**: All spaces go to one server.

**Solutions**:
- Verify all servers are in the cluster (**Admin** → **Cluster Info**)
- Verify each server has a container runtime configured and running
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

- [Node Selection](/docs/configuration/node-selection/) - Learn how spaces are assigned to servers
- [Configuration](/docs/configuration/) - Detailed configuration options
- [Cluster Architecture](/reference/architecture/cluster-architecture/) - Deep dive on clustering
- [Troubleshooting](/docs/troubleshooting/) - Common issues and solutions
