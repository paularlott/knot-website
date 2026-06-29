---
title: Scalability
weight: 40
---

Scaling strategies and performance optimization.

---

## Vertical Scaling

Increase resources on existing servers:
- More CPU for handling requests
- More memory for caching
- Faster storage for database
- Better network for throughput

**Limits**: Single server capacity

---

## Horizontal Scaling

Add more servers to cluster:
- Distribute load across servers
- Place servers near users
- Increase redundancy
- No practical limit

**Requirements**: Database that scales

---

## Database Scaling

**MySQL/MariaDB**:
- Master-replica replication
- Cluster configurations
- Read replicas for queries

**Redis/Valkey**:
- Cluster mode
- Sentinel for HA
- Sharding for capacity

---

## Performance Considerations

### Latency

**Factors**:
- Distance between user and server
- Network quality
- Server load
- Database performance

**Solutions**:
- Place servers near users (zones)
- Use leaf mode for remote users
- Optimize database queries
- Cache frequently accessed data

### Throughput

**Factors**:
- Number of concurrent users
- Space creation rate
- API request volume
- Database capacity

**Solutions**:
- Horizontal scaling (more servers)
- Database optimization
- Connection pooling
- Rate limiting

### Resource Usage

**Server resources**:
- CPU: Request handling, data processing
- Memory: Caching, active connections
- Storage: Database, logs, temporary files
- Network: Client connections, agent communication

**Optimization**:
- Right-size server resources
- Monitor resource usage
- Scale before hitting limits
- Regular maintenance
