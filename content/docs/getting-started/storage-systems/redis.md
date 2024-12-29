---
title: Redis / Valkey
weight: 60
---

## Standalone Redis / Valkey Server

The knot server can be run using a Redis or Valkey server or cluster by setting `redis.enabled` to `true` in the configuration file:

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
    enabled: false
    path: /badgerdb/

  # Redis storage
  redis:
    enabled: true
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

## Redis / Valkey Sentinel

When using Redis / Valkey Sentinel the `hosts` should be a list of sentinels and the `master_name` should given and set to the name of the master.

```yaml {filename=knot.yml}
server:
  redis:
    enabled: true
    # Redis host if prefixed with srv+ then SRV+ lookup will be performed
    hosts:
      - 192.168.0.10:5000
      - 192.168.0.11:5000
      - 192.168.0.12:5000
    password: ""
    db: 0
    master_name: "mymaster"
```

## Redis / Valkey Cluster

When using Redis Cluster the `hosts` should be a list of master nodes in the cluster.

```yaml {filename=knot.yml}
server:
  redis:
    enabled: true
    # Redis host if prefixed with srv+ then SRV+ lookup will be performed
    hosts:
      - 192.168.0.10:6379
      - 192.168.0.11:6379
      - 192.168.0.12:6379
    password: ""
    db: 0
```
