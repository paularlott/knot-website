---
title: Server Install
weight: 20
---

knot requires the deployment of a server component. This component is responsible for overseeing the user environments, managing users, and regulating access to active spaces. There are two options available for deploying the server: it can be installed on a virtual machine or deployed as a Nomad job. The rest of this guide focuses on the Nomad based deployment.

## The Job File

The latest example of the job file can be generated by running the following command:

```bash
knot scaffold --nomad
```

The output of the command will generate the following, this can't be directly deployed as it needs updating to match the Nomad cluster and MySQL server.

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
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
  agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

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

      # Knot Agent Port
      service {
        name = "${NOMAD_JOB_NAME}"
        port = "knot_port"

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

## Configuration

`datacenters` will need updating for the cluster that the job is being deployed to as will the `tags` so that the ingress controller can route traffic to the server.

The knot server is configured via the `local/knot.yml` file:

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
	agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

  mysql:
      database: knot
      enabled: true
      host: ""
      password: ""
      user: ""

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

The configuration should be updated:

- `url` The host the server will be accessed as
- `wildcard_domain` The wildcard domain used to provide web access to the containers web server
- `agent_endpoint` The endpoint agents should connect to
- `encrypt` The encryption key for encrypting variables, this is generated with `knot genkey`
- `mysql.*` The configuration information for the MySQL server to use
- `nomad.*` The configuration for communicating with Nomad, the token must have permission to access any namespaces used in environment jobs

The MySQL database should be empty as on first run knot will create the required tables and initialize the data.

### Caching

#### Redis / Valkey

A Redis or Valkey server or cluster can be used along side MySQL to store session information, this is more performant than storing the sessions in the database.

To enable caching simply add a redis configuration e.g.:

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
	agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

  mysql:
      database: knot
      enabled: true
      host: ""
      password: ""
      user: ""

  redis:
    enabled: true
    host: srv+redis.service.consul
    password: ""
    db: 0

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

In this mode all data is stored in MySQL only the sessions are stored in redis.


#### MemoryDb

The session data can be stored in a memory database, this is the most performant option, however restarting the server will loose the current sessions.

To enable  memory basedcaching simply add a `memorydb` configuration e.g.:

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
	agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

  mysql:
      database: knot
      enabled: true
      host: ""
      password: ""
      user: ""

  memorydb:
    enabled: true

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

In this mode all data is stored in MySQL only the sessions are stored in memory.

### Without MySQL

#### Redis / Valkey

The knot server can be run using a Redis / Valkey server by replacing knot.yml in the nomad job:

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
	agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

  redis:
    enabled: true
    hosts:
      - srv+redis.service.consul
    password: ""
    db: 0

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

#### Redis / Valkey Sentinel

When using Redis / Valkey Sentinel the `hosts` should be a list of sentinels and the `master_name` should given and set to the name of the master.

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
	agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

  redis:
    enabled: true
    hosts:
      - 192.168.0.10:5000
      - 192.168.0.11:5000
      - 192.168.0.12:5000
    master_name: "mymaster"
    password: ""
    db: 0

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

#### Redis / Valkey Cluster

When using Redis Cluster the `hosts` should be a list of master nodes in the cluster.

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
	agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

  redis:
    enabled: true
    hosts:
      - 192.168.0.10:6379
      - 192.168.0.11:6379
      - 192.168.0.12:6379
    password: ""
    db: 0

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

#### BadgerDB

The knot server can be run without MySQL by using the embedded BadgerDB by replacing knot.yml in the nomad job:

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
	listen_agent: 0.0.0.0:3010
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
	agent_endpoint: "srv+knot-server-agent.service.consul"
  encrypt: "knot genkey"

  badgerdb:
    enabled: true
    path: /data/

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

The `/data/` directory must be mounted to persistent storage or configurations are not persisted between restarts.
