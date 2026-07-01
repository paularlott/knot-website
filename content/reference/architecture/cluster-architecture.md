---
title: Cluster Architecture
weight: 20
---

How knot's leaderless cluster works.

---

## Leaderless Design

Traditional clusters have a leader node that coordinates operations. If the leader fails, a new leader must be elected, causing downtime.

Knot uses a leaderless architecture where all servers are equal.

**Benefits**:
- No single point of failure
- No leader election delays
- Servers can be added/removed dynamically
- Continues operating if nodes are disconnected
- Better performance distribution

**How it works**:
- Each server has own database
- Changes synchronized via gossip protocol
- Each server can handle any request
- No coordination overhead
- Eventual consistency model

---

## Data Flow

### Space Creation

1. User creates space via web interface
2. Server stores space metadata in database
3. Server provisions volumes (if needed)
4. Server starts container with agent
5. Agent connects to server
6. Space becomes available

### Space Access

1. User accesses space via web terminal or SSH
2. Request goes to any server in cluster
3. Server looks up space in database
4. Server connects to agent in space
5. Connection established

### Template Updates

1. Admin updates template
2. Change saved to database
3. All servers see update immediately
4. Running spaces marked for update
5. Update applied on next space restart

---

## High Availability

### Server Redundancy

Run multiple servers in cluster:
- Minimum 3 servers recommended
- Distribute across availability zones
- Load balancer in front of servers
- Health checks and failover

### Database Redundancy

Use database HA features:
- MySQL replication or clustering
- Redis Sentinel or Cluster
- Regular backups
- Automated failover

### Storage Redundancy

For Nomad deployments:
- Use replicated CSI storage
- Regular volume backups
- Disaster recovery plan

---

## Disaster Recovery

### Backup Strategy

- Regular database backups
- Encrypted backup storage
- Offsite backup copies
- Tested restore procedures

### Recovery Plan

1. Identify failure scope
2. Restore database from backup
3. Restart servers
4. Verify system functionality
5. Notify users

### Business Continuity

- Document recovery procedures
- Define RTO (Recovery Time Objective)
- Define RPO (Recovery Point Objective)
- Regular DR testing
- Maintain spare capacity
