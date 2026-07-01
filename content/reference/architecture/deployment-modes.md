---
title: Deployment Modes
weight: 10
---

Knot supports three deployment modes for different use cases.

---

## Standalone

Single server running knot with local containers.

{{< mermaid >}}
flowchart TD
  User(["User · Browser · SSH"])
  Server["Knot Server"]
  DB[("BadgerDB")]
  Runtime["Container Runtime\nDocker · Podman · Apple Containers"]
  Space["Space"]
  Agent["Agent"]

  User -->|HTTPS / SSH| Server
  Server --- DB
  Server -->|provision| Runtime
  Runtime --- Space
  Space --- Agent
  Agent -->|connect| Server
{{< /mermaid >}}

**Characteristics**:
- Simple setup
- No external dependencies
- Single point of failure
- Limited scalability
- Good for small teams

**Best for**:
- Individual developers
- Small teams (< 10 users)
- Development and testing
- Simple deployments

---

## Cluster Mode

Multiple servers with gossip-based synchronization.

{{< mermaid >}}
flowchart TD
  User(["User · Browser · SSH"])
  LB["Load Balancer"]
  SA["Server A\nZone A"]
  SB["Server B\nZone B"]
  SC["Server C\nZone C"]
  DBA[("MariaDB")]
  DBB[("Redis")]
  DBC[("BadgerDB")]

  User --> LB
  LB --> SA
  LB --> SB
  LB --> SC
  SA --- DBA
  SB --- DBB
  SC --- DBC
  SA <-.->|gossip| SB
  SB <-.->|gossip| SC
  SA <-.->|gossip| SC
{{< /mermaid >}}

Each server runs its own database backend — BadgerDB (embedded), MariaDB, or Redis — and replicates changes to peers over the gossip protocol (leaderless). See [High Availability](../cluster-architecture/#database-redundancy) for database redundancy options.

**Characteristics**:
- High availability
- Geographic distribution
- No single point of failure
- Leaderless architecture
- Each server has own database
- Data syncs via gossip protocol
- Scales horizontally

**Best for**:
- Production deployments
- Distributed teams
- High availability requirements
- Multiple geographic locations

---

## Leaf Mode

Local server connected to cluster server with own storage.

{{< mermaid >}}
flowchart TD
  subgraph Cluster["Central Cluster"]
    direction TB
    S1["Server 1"]
    S2["Server 2"]
    S3["Server 3"]
    S1 <-.->|gossip| S2
    S2 <-.->|gossip| S3
    S1 <-.->|gossip| S3
  end

  subgraph Leaf["Leaf Node · local machine"]
    LDB[("BadgerDB")]
    LR["Container Runtime"]
    LSp["Space"]
  end

  S2 <-.->|gossip sync| LDB
  LDB --- LR
  LR --- LSp
{{< /mermaid >}}

**Characteristics**:
- Connects to one cluster server
- Own local storage (BadgerDB)
- Syncs via gossip protocol
- Central template management
- Local execution
- Reduced latency
- Works offline (cached data)
- Hybrid deployment

**Best for**:
- Remote developers
- Local development with central management
- Bandwidth-constrained locations
- Hybrid deployments

---

## Zones and Locations

Zones organize servers geographically or logically:

**Geographic zones**:
- `us-east`: Servers in US East Coast
- `eu-west`: Servers in Western Europe
- `asia-pacific`: Servers in Asia Pacific

**Logical zones**:
- `production`: Production servers
- `development`: Development servers
- `testing`: Testing servers

**Benefits**:
- Place spaces near users for low latency
- Organize resources logically
- Control where spaces run
- Compliance with data residency

**Configuration**:
```toml
[server]
zone = "us-east"
```

Templates can be limited to specific zones.
