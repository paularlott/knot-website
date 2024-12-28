---
title: Installing a Leaf Server
weight: 30
cascade:
  type: docs
---

Once you have a single server running, you can add more servers. These additional servers, Leaf Servers, can be used to improve performance by placing clusters close to the users, to provide additional capacity within a location or to provide separation between different teams.

## Origin Server

Firstly the original server configuration needs to be updated to allow it to become the Origin Server. The `shared_token` option needs to be added to the configuration, this should be a random string that is shared with the Leaf Servers, the value needs to be kept secret.

Each Origin and Leaf server requires a unique `location` value, this is used to identify the server in the web interface and the spaces controlled by the server.

```yaml {filename=knot.yaml}
server:
  shared_token: L5Eh3a2bwZJCIsT7xl6NiPXcLz1aBt5T
  location: origin
```

After making these changes restart the server.

## Leaf Server

### Configuration

An example configuration file can be generated using the `knot scaffold --server` command:

```yaml {filename=knot.yaml}
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
    path: ./badgerdb/

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

The following items need to be configured in the `knot.yaml` file in addition to the base configuration:

- `shared_token` - The shared token that is used to authenticate the Leaf Server with the Origin Server, this must match the Origin Server.
- `location` - The location of the server.
- `origin_server` - The address of the Origin Server.

