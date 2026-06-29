---
title: Deployment Modes
weight: 10
---

Knot supports three deployment modes for different use cases.

---

## Standalone

Single server running knot with local containers.

![Standalone Architecture](/images/diagrams/standalone.svg)

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

![Cluster Architecture](/images/diagrams/cluster.svg)

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

![Leaf Mode Architecture](/images/diagrams/leaf.svg)

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
