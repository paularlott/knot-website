---
title: Standalone Server
weight: 20
cascade:
  type: docs
---

The server requires a configuration file, environment variables can also be used, but the configuration file is the preferred method.

This first server will become the Origin Server, additional servers can be added as Leaf Servers when choosing to run multiple servers.

A configuration file can be generated using the `knot scaffold --server` command:

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

A storage method will need to be chosen and enabled e.g. MySQL, also the following will need to be set to allow agents and users to connect:

- `listen` - The address and port to listen on for web traffic
- `listen_agent` - The address and port to listen on for agents
- `agent_endpoint` - The address and port that agents will connect to
- `wildcard_domain` - The wildcard domain to expose the web interface of spaces on
- `encrypt` - Replace this using the output from `knot genkey`
- `location` - Optional server location, defaults to the hostname, this should be set when planning to deploy multiple servers

## Standalone Server

To run a standalone server download the latest release from the [releases page](https://github.com/paularlott/knot/releases/latest) and run the following command:

```shell
./knot server --config knot.yml
```

{{< tip >}}
  For macOS and Linux knot can be installed via brew with `brew install paularlott/tap/knot`
{{< /tip >}}

```shell

## Nomad Job

When running as a Nomad job an example job file can be generated withe the `knot scaffold --nomad` command:

```hcl {filename=knot-server.nomad}
job "knot-server" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = true
  }

  group "knot-server" {
    count = 1

    network {
      port "knot_port" {
        to = 3000
      }
      port "knot_agent_port" {
        to = 3010
      }
    }

    task "knot-server" {
      driver = "docker"
      config {
        image = "paularlott/knot:latest"
        ports = ["knot_port", "knot_agent_port"]
      }

      env {
        KNOT_CONFIG = "/local/knot.yml"
      }

      template {
        data = <<EOF
log:
  level: info
server:
  listen: 0.0.0.0:3000
  listen-agent: 0.0.0.0:3010
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
  agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "Gnat9SAejFszCla9n1FjCIXQb3py5i0w" # Replace this using knot genkey

  mysql:
      database: knot
      enabled: true
      host: ""
      password: ""
      user: ""

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
EOF
        destination = "local/knot.yml"
      }

      resources {
        cpu = 256
        memory = 512
      }

      # Knot Server Port
      service {
        name = "${NOMAD_JOB_NAME}"
        port = "knot_port"
        address = "${attr.unique.network.ip-address}"

        # Expose the port on a domain name
        # tags = [
        #  "urlprefix-knot.example.com proto=https tlsskipverify=true",
        #  "urlprefix-*.knot.example.com proto=https tlsskipverify=true"
        # ]

        check {
          name            = "alive"
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/health"
          interval        = "10s"
          timeout         = "2s"
        }
      }

      service {
        name = "${NOMAD_JOB_NAME}-agent"
        port = "knot_agent_port"
        address = "${attr.unique.network.ip-address}"

        check {
          name            = "alive"
          port            = "knot_port"
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/health"
          interval        = "10s"
          timeout         = "2s"
        }
      }
    }
  }
}
```

- `datacenters` - Will need to be update to match the Nomad cluster
- `local/knot.yml` - The configuration file for the server will need to be updated as required, the example configuration file can be generated with `knot scaffold --server`
- The knot ports will need to be exposed to the clusters ingress controller

