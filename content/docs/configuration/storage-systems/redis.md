---
title: Redis / Valkey
weight: 60
---

The **knot** server can be configured to use Redis / Valkey as the database storage. It supports both single-server mode and high-availability cluster setups.

{{< tip >}}
Redis / Valkey can be enabled alongside another storage system (e.g., MySQL). In such cases, Redis / Valkey is used exclusively for session data.
{{< /tip >}}

---

### Single Redis / Valkey Server

To configure the **knot** server with a single Redis / Valkey server, set `redis.enabled` to `true` in the configuration file:

```toml {{filename="knot.toml"}}
[server.redis]
  enabled = true
  hosts = [
    "localhost:6379"
  ]
  password = ""
  db = 0
```

#### Configuration Parameters

- **`enabled`**: Must be set to `true` to enable the use of Redis / Valkey.
- **`hosts`**: The hostname or IP address of the Redis / Valkey server. If the hostname has a `srv+` prefix, the SRV record will be looked up to resolve the hostname and port number.
- **`password`**: The optional password to connect to the server.
- **`db`**: The Redis / Valkey database number to use.

---

### Redis / Valkey Sentinel

When using Redis / Valkey Sentinel, the `hosts` should include a list of Sentinel nodes, and the `master_name` must be set to the name of the master.

```toml {{filename="knot.toml"}}
[server.redis]
  enabled = true
  hosts = [
    "192.168.0.10:5000",
    "192.168.0.11:5000",
    "192.168.0.12:5000"
  ]
  password = ""
  db = 0
  master_name = "mymaster"
```

#### Configuration Parameters

- **`enabled`**: Must be set to `true` to enable the use of Redis / Valkey.
- **`hosts`**: A list of hostnames or IP addresses of the Redis / Valkey Sentinel nodes. If the hostname has a `srv+` prefix, the SRV record will be looked up to resolve the hostname and port number.
- **`password`**: The optional password to connect to the server.
- **`db`**: The Redis / Valkey database number to use.
- **`master_name`**: The name of the master node.

---

### Redis / Valkey Cluster

For Redis / Valkey Cluster, the `hosts` should include a list of master nodes in the cluster.

```toml {{filename="knot.toml"}}
[server.redis]
  enabled = true
  hosts = [
    "192.168.0.10:6379",
    "192.168.0.11:6379",
    "192.168.0.12:6379"
  ]
  password = ""
  db = 0
```

#### Configuration Parameters

- **`enabled`**: Must be set to `true` to enable the use of Redis / Valkey.
- **`hosts`**: A list of hostnames or IP addresses of the Redis / Valkey master nodes. If the hostname has a `srv+` prefix, the SRV record will be looked up to resolve the hostname and port number.
- **`password`**: The optional password to connect to the server.
- **`db`**: The Redis / Valkey database number to use, must always be `0` for a cluster.
