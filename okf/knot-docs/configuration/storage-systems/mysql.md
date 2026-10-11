---
description: Configure MySQL or MariaDB, including Galera cluster setups, for data storage.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/configuration/storage-systems/mysql/
sources:
    - resource: https://getknot.dev/docs/configuration/storage-systems/mysql/
status: stable
tags:
    - storage
    - configuration
title: MySQL / MariaDB
type: Guide
---
# MySQL / MariaDB

The Knot server can be configured to use either a standalone MySQL / MariaDB server or a Galera cluster for its database. To enable this, you need to update the configuration file and provide the necessary connection details.


Knot releases before 0.37.0 could fail to create their tables on a new MySQL 8 (or later) database. Use 0.37.0 or later for new MySQL 8 installations.


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

- **`database`**: The name of the database to use. It should be an empty database, as it will be populated automatically on the first boot of the Knot server.

- **`enabled`**: Must be set to `true` to enable the use of MySQL / MariaDB.

- **`host`**: The database server to connect to. This can be:
  - A hostname (e.g., `db.example.com`)
  - An IP address (e.g., `192.168.1.100`)
  - If prefixed with `srv+`, an SRV record (e.g., `srv+db.service.consul`) to look up both the host and port.

- **`port`**: The port the database server is running on. This is not used when using SRV records.

- **`user`**: The username to connect with.

- **`password`**: The password for the specified user.

- **`connection_max_idle`**, **`connection_max_open`** and **`connection_max_lifetime`**: The size of the connection pool, by default 10 idle and 100 open connections, each reused for at most 5 minutes.

Each option can also be set with a command line flag, such as `--mysql-host`, or an environment variable, such as `KNOT_MYSQL_HOST`.

---

### Sessions

MySQL / MariaDB isn't used for sessions. Without Redis / Valkey, sessions are held in memory on each server, so restarting the server signs users out. To keep users signed in across restarts, use [PostgreSQL](postgres.md) or enable [Redis / Valkey](redis.md) alongside MySQL / MariaDB for sessions.
