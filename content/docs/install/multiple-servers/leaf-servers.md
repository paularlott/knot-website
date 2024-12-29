---
title: Leaf Servers
weight: 60
---

Leaf servers allow the placement of servers close to developers to minimize latency while allowing management of users and templates from a central location, the origin server.

Leaf servers are considered trusted and will have full access to all data within the origin server. To create a leaf server start the server with the shared token and the address of the origin server using the options `--shared-token` and `--origin-server` or using the environment variables `KNOT_SHARED_TOKEN` and `KNOT_ORIGIN_SERVER`, e.g.

```
KNOT_SHARED_TOKEN=IoiQiTe0ys6ZVoNYongjVTk1kgIbAN8U
KNOT_ORIGIN_SERVER=https://knot.example.com
```

All other configuration options are as per the origin server, however there's no need to use the same database backend for leaf servers, the origin server could use a Galera Cluster while the leaf servers could use a redis server. The storage requirements of leaf servers is less than the origin server as they don't hold a complete copy of all the data.
