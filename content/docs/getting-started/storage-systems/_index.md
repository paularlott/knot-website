---
title: Storage Systems
weight: 25
---

knot can make use of multiple storage systems for storing data. The following storage systems are supported:

- MySQL / MariaDB, requires a MySQL or MariaDB server or Galera cluster.
- BadgerDB, no external dependencies required.
- Redis / Valkey, requires a Redis or Valkey server or cluster. Can be used for session storage or for storing all data.
- Memory, in-memory database, no external dependencies but only suitable for session storage.
