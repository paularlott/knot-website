---
title: Origin & Leaf Servers
weight: 25
---

Leaf servers allow the placement of servers close to developers to minimize latency while allowing management of users and templates from a central location, the origin server.

## Origin Server

To allow the origin server to support leaf servers it needs to be started with the `--shared-token` option or using the environment variable `KNOT_SHARED_TOKEN`, this should be set to an authentication string which will be shared with the leaf servers e.g.

```
KNOT_SHARED_TOKEN=IoiQiTe0ys6ZVoNYongjVTk1kgIbAN8U
```

## Leaf Servers

Leaf servers have to be started with the shared token and the address of the origin server using the options `--shared-token` and `--origin-server` or using the environment variables `KNOT_SHARED_TOKEN` and `KNOT_ORIGIN_SERVER`, e.g.

```
KNOT_SHARED_TOKEN=IoiQiTe0ys6ZVoNYongjVTk1kgIbAN8U
KNOT_ORIGIN_SERVER=https://knot.example.com
```

All other configuration options are as per the origin server.

There's no need to use the same database backend for leaf servers, the origin server could use a Galera Cluster while the leaf servers could use a redis cluster. The storage requirements of leaf servers is less than the origin server as they don't hold a complete copy of all the data.

{{< callout type="info" >}}
  Leaf servers must be able to connect to the origin server however there's no requirement for origin servers to be able to connect to leaf servers.
{{< /callout >}}
