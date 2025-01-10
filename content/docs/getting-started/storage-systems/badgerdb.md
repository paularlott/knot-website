---
title: BadgerDB
weight: 50
---

The knot server can be run using only the embedded BadgerDB by setting `badgerdb.enabled` to `true` in the configuration file:

```yaml {filename=knot.yml}
# Server configuration
server:
  # Address and port to listen on
  listen: http://127.0.0.1:3000

  # Address and port to listen on for agents
  listen_agent: 0.0.0.0:3010

  # Address and port for the agents to connect to
  agent_endpoint: "srv+knot-server-agent.service.consul"

  # The wildcard domain to expose the web interface of spaces on
  # wildcard_domain: '*.example.com'

  # Disable Proxy functionality
  disable_proxy: false

  terminal:
    webgl: true

  # Encryption key for protected variables
  # encrypt: VF9hmdXZyzNF3rcP6M0P

  # Optional server location, defaults to the hostname
  # location: myservers

  # Shared secret when using leaf servers with an origin server
  # shared_token: secret

  # Enables leaf servers to work in a restricted mode using API tokens
  # enable_leaf_api_tokens: true

  # The address of the origin server, when given along with shared_token the server will be configured as a leaf server
  # origin_server: https://knot-origin.ecample.com:3000

  # MySQL storage
  mysql:
    enabled: false
    # MySQL host if prefixed with srv+ then SRV+ lookup will be performed
    host: localhost
    port: 3306
    user: root
    password: ""
    database: knot

  # BadgerDB storage
  badgerdb:
    enabled: true
    path: /badgerdb/

  # Redis storage
  redis:
    enabled: false
    # Redis host if prefixed with srv+ then SRV+ lookup will be performed
    hosts:
      - localhost:6379
    password: ""
    db: 0

  # Memory database (only used for session storage if enabled)
  memorydb:
    enabled: false

  nomad:
    addr: http://127.0.0.1:4646
    token: ""

# Optional nameservers to use for SRV lookups
#resolver:
#  consul:
#    - 192.168.0.4:8600
#  nameservers:
#    - 192.168.0.2:53

log:
  level: info
```

The `/badgerdb/` directory must be mounted to persistent storage or configurations will not be persisted between restarts.

## Sessions in MemoryDB

By default, the BadgerDB is used for storing all data including sessions information. Setting `memorydb.enabled` to `true` in the configuration file will make knot use the in-memory database for storing session information:

```yaml {filename=knot.yml}
server:
  memorydb:
    enabled: true
```

{{< callout type="warning" >}}
  When using the in-memory database, all session information will be lost when the server is restarted.
{{< /callout >}}

## Sessions in Redis / Valkey

Redis or Valkey can be used for session storage by setting `redis.enabled` to `true` in the configuration file.

```yaml {filename=knot.yml}
server:
  redis:
    enabled: false
    # Redis host if prefixed with srv+ then SRV+ lookup will be performed
    hosts:
      - localhost:6379
    password: ""
    db: 0
```
