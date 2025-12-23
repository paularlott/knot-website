---
title: Storage Systems
weight: 10
---

The **knot** server supports multiple storage systems for managing data. Each storage option is designed to cater to different use cases and deployment requirements. Below is an overview of the supported storage systems:

---

### 1. MySQL / MariaDB

- **Description**: Requires a MySQL or MariaDB server or a Galera cluster. Ideal for setups that need a robust, external database with advanced features like clustering and high availability.

- **Use Case**: Suitable for production environments where scalability and reliability are critical.

---

### 2. BadgerDB

- **Description**: An embedded database with no external dependencies. Data is stored locally, making it a simple and lightweight option that's production-ready.

- **Use Case**: Ideal for most deployments, including multi-server clusters where data is replicated between servers via gossip protocol. Perfect for teams wanting simplicity without external database infrastructure.

---

### 3. Redis / Valkey

- **Description**: Requires a Redis or Valkey server or cluster. Can be used as the primary storage system or in combination with another storage system (e.g., MySQL). When used alongside another system, Redis / Valkey is utilized exclusively for session data.

- **Use Case**: Ideal for setups requiring fast, in-memory data storage or session management. High availability and clustering options make it suitable for distributed environments.

---

Each storage system offers unique benefits, allowing you to choose the one that best fits your deployment needs. For detailed configuration instructions, refer to the respective guides:

- [MySQL / MariaDB Configuration](../mysql-mariadb)
- [BadgerDB Configuration](../badgerdb)
- [Redis / Valkey Configuration](../redis-valkey)
