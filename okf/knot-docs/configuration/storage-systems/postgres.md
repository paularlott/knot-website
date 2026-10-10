---
description: Configure PostgreSQL for data and session storage.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/configuration/storage-systems/postgres/
sources:
    - resource: https://getknot.dev/docs/configuration/storage-systems/postgres/
status: stable
tags:
    - storage
    - configuration
title: PostgreSQL
type: Guide
---
# PostgreSQL

The Knot server can use PostgreSQL for its database. PostgreSQL also stores sessions, so users stay signed in when a server restarts, without needing Redis / Valkey.

---

### Configuration

To use PostgreSQL, set `postgres.enabled` to `true` in the configuration file and specify the connection details as shown below:

```toml {{filename="knot.toml"}}
[server.postgres]
  enabled = true
  host = "srv+postgres.service.consul"
  port = 5432
  user = "<database user>"
  password = "<database password>"
  database = "knot"
  sslmode = "prefer"
```

---

### Configuration Parameters

- **`database`**: The name of the database to use. It should be an empty database, as it will be populated automatically on the first boot of the Knot server. Each Knot server needs its own database.

- **`enabled`**: Must be set to `true` to enable the use of PostgreSQL.

- **`host`**: The database server to connect to. This can be:
  - A hostname (e.g., `db.example.com`)
  - An IP address (e.g., `192.168.1.100`)
  - If prefixed with `srv+`, an SRV record (e.g., `srv+postgres.service.consul`) to look up both the host and port.

- **`port`**: The port the database server is running on, `5432` by default. This is not used when using SRV records.

- **`user`**: The username to connect with.

- **`password`**: The password for the specified user.

- **`sslmode`**: How the connection uses TLS: `disable`, `allow`, `prefer` (the default), `require`, `verify-ca` or `verify-full`.

- **`connection_max_idle`**, **`connection_max_open`** and **`connection_max_lifetime`**: The size of the connection pool, by default 10 idle and 100 open connections, each reused for at most 5 minutes.

Each option can also be set with a command line flag, such as `--postgres-host`, or an environment variable, such as `KNOT_POSTGRES_HOST`.

---

### Sessions

When PostgreSQL is the database, sessions are stored in it and kept when a server restarts. As with BadgerDB and MySQL, the servers in a cluster share sessions with each other over gossip, so each server can keep its own database.

If Redis / Valkey is also enabled, sessions are stored in Redis / Valkey instead, as with the other databases. See [Redis / Valkey](redis.md). Sessions aren't moved between the two, so turning Redis / Valkey on or off signs everyone out once.
