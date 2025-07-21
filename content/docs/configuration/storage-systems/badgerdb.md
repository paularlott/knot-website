---
title: BadgerDB
weight: 50
---

The **knot** server can be configured to use the embedded BadgerDB for its database. This option is ideal for simpler setups where an external database is not required. To enable BadgerDB, update the configuration file as shown below.

---

### Configuration

To use BadgerDB, set `badgerdb.enabled` to `true` in the configuration file and specify the storage path:

```toml
[server.badgerdb]
  enabled = true
  path = "/badgerdb/"
```

---

### Configuration Parameters

- **`enabled`**: Must be set to `true` to enable the use of BadgerDB.

- **`path`**: The directory where BadgerDB files will be stored. This directory **must** be mounted to persistent storage to ensure configurations are preserved between restarts of the **knot** server.
