---
title: MemoryDB
weight: 70
---

The session data can be stored in a memory database, this is the most performant option for session storage.

```yaml {filename=knot.yml}
server:
  memorydb:
    enabled: true
```

The MemoryDB can only be used for session storage therefore another storage system must be used for storing all other data.

{{< callout type="warning" >}}
  When using the in-memory database, all session information will be lost when the server is restarted.
{{< /callout >}}
