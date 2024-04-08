---
title: Remote Servers
weight: 25
---

Remote servers allow the placement of servers close to developers to minimize latency while allowing management of users and templates from a central location.

## Core Server

To allow the core server to support remote servers it needs to be started with the `--remote-token` option or using the environment variable `KNOT_REMOTE_TOKEN`, this should be set to an authentication string which will be shared with the remote servers e.g.

```
KNOT_REMOTE_TOKEN=IoiQiTe0ys6ZVoNYongjVTk1kgIbAN8U
```

## Remote Servers

Remote servers have to be started with the shared token and the address of the core server using the options `--remote-token` and `--core-server` or using the environment variables `KNOT_REMOTE_TOKEN` and `KNOT_CORE_SERVER`, e.g.

```
KNOT_REMOTE_TOKEN=IoiQiTe0ys6ZVoNYongjVTk1kgIbAN8U
KNOT_CORE_SERVER=https://knot.example.com
```

All other configuration options are as per the core server.

There's no need to use the same database backend for remote servers, the core server could use a Galera Cluster while the remote servers could use a redis cluster. The storage requirements of remote servers is less than the core servers as they don't hold a complete copy of all the data.

{{< callout type="warning" >}}
  Remote servers must be able to connect to the core server and the core server must be able to connect to the remote servers.
{{< /callout >}}
