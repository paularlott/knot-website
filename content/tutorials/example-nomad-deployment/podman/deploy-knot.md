---
title: Deploy Knot
weight: 30
---

Below is the Nomad job specification for deploying the **knot** server using **Podman**:

```hcl {filename="knot.hcl"}
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
        static = 3000
      }
      port "knot_agent_port" {
        to = 3010
        static = 3010
      }
      port "knot_tunnel_port" {
        to = 3001
        static = 3001
      }
    }

    task "knot-server" {
      driver = "podman"
      config {
        image = "registry-1.docker.io/paularlott/knot:latest"
        ports = ["knot_port", "knot_agent_port", "knot_tunnel_port"]
      }

      env {
        KNOT_CONFIG = "/local/knot.toml"
      }

      template {
        data = <<EOF
[log]
  level = "info"

[resolver]
  nameservers = ["1.1.1.1", "1.0.0.1", "consul/{{ env "NOMAD_IP_knot_port" }}:8600"]

[server]
  # agent_endpoint = "srv+knot-server-agent.service.consul"
  agent_endpoint = "192.168.0.10:3010"
  listen = "0.0.0.0:3000"
  listen_agent = "0.0.0.0:3010"
  url = "https://knot.getknot.dev"
  wildcard_domain = "*.knot.getknot.dev"
  encrypt = "2gJcpKPGqDK8JWUCdgCeQQx1uZwP8fhe"
  listen_tunnel = "0.0.0.0:3001"
  tunnel_domain = "*.tunnel.getknot.dev"
  [server.badgerdb]
    enabled = false
    path = "./badgerdb/"
  [server.mysql]
    database = "knot"
    enabled = false
    host = "localhost"
    password = ""
    port = 3306
    user = "root"
  [server.nomad]
    addr = "http://{{ env "NOMAD_IP_knot_port" }}:4646"
    token = ""
  [server.redis]
    db = 0
    enabled = true
    hosts = ["{{ env "NOMAD_IP_knot_port" }}:6379"]
    password = ""
  [server.terminal]
    webgl = true
EOF
        destination = "local/knot.toml"
      }

      resources {
        cpu = 256
        memory = 512
      }

      service {
        name = "${NOMAD_JOB_NAME}"
        port = "knot_port"
        address = "${attr.unique.network.ip-address}"

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
          type            = "http"
          protocol        = "https"
          port            = "knot_port"
          tls_skip_verify = true
          path            = "/health"
          interval        = "10s"
          timeout         = "2s"
        }
      }

      service {
        name = "${NOMAD_JOB_NAME}-tunnel"
        port = "knot_tunnel_port"
        address = "${attr.unique.network.ip-address}"

        check {
          name            = "alive"
          type            = "http"
          protocol        = "https"
          port            = "knot_port"
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

---

## Deploy the Knot Server

To deploy the **knot** server, run the following command:

```shell
nomad run knot.hcl
```
