---
title: Origin Servers
weight: 50
---

The origin server is the central server which manages all the users, templates and other resources, it can support developers and spaces although it doesn't have to.

To allow a server to become an origin server it needs to be started with the `--shared-token` option or using the environment variable `KNOT_SHARED_TOKEN`, this should be set to an authentication string which will be shared with the leaf servers e.g.

```
KNOT_SHARED_TOKEN=IoiQiTe0ys6ZVoNYongjVTk1kgIbAN8U
```

The storage backend used by an origin server should be more robust that that used by other server types as it will hold the complete set of data including all the user credentials.

{{< callout type="warning" >}}
  Origin servers must be configured so that all leaf servers can connect to them via their public domain name.

  However there is no requirement for origin servers to be able to connect to leaf servers and communication between servers is performed over the leaf initiated connection.
{{< /callout >}}
