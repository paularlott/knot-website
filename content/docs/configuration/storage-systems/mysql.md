---
title: MySQL / MariaDB
weight: 40
---

The **knot** server can be configured to use either a standalone MySQL / MariaDB server or a Galera cluster for its database. To enable this, you need to update the configuration file and provide the necessary connection details.

---

### Configuration

To use MySQL / MariaDB, set `mysql.enabled` to `true` in the configuration file and specify the connection details as shown below:

```toml {{filename="knot.toml"}}
[server.mysql]
  database = "knot"
  enabled = true
  host = "srv+db.service.consul"
  port = 3306
  password = "<database password>"
  user = "<database user>"
```

---

### Configuration Parameters

- **`database`**: The name of the database to use. It should be an empty database, as it will be populated automatically on the first boot of the **knot** server.

- **`enabled`**: Must be set to `true` to enable the use of MySQL / MariaDB.

- **`host`**: The database server to connect to. This can be:
  - A hostname (e.g., `db.example.com`)
  - An IP address (e.g., `192.168.1.100`)
  - If prefixed with `srv+`, an SRV record (e.g., `srv+db.service.consul`) to look up both the host and port.

- **`port`**: The port the database server is running on. This is not used when using SRV records.

- **`user`**: The username to connect with.

- **`password`**: The password for the specified user.
