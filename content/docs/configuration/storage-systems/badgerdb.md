---
title: BadgerDB
description: Configure the embedded BadgerDB database for single and multi-server deployments.
type: Guide
tags: [storage, configuration]
weight: 50
---

The Knot server can be configured to use the embedded BadgerDB for its database. BadgerDB is production-ready and works well for single-server and multi-server deployments (data is synced between servers via gossip protocol). To enable BadgerDB, update the configuration file as shown below.

---

### Configuration

To use BadgerDB, set `badgerdb.enabled` to `true` in the configuration file and specify the storage path:

```toml {{filename="knot.toml"}}
[server.badgerdb]
  enabled = true
  path = "/badgerdb/"
```

The same settings via flags or environment variables:

```shell
knot server --badgerdb-enabled --badgerdb-path /var/lib/knot/badger
```

| Config | Flag | Environment |
|---|---|---|
| `server.badgerdb.enabled` | `--badgerdb-enabled` | `KNOT_BADGERDB_ENABLED` |
| `server.badgerdb.path` | `--badgerdb-path` | `KNOT_BADGERDB_PATH` |

---

### Configuration Parameters

- **`enabled`**: Must be set to `true` to enable the use of BadgerDB.

- **`path`**: The directory where BadgerDB files will be stored. This directory **must** be mounted to persistent storage to ensure configurations are preserved between restarts of the Knot server.
