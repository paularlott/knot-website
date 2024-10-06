---
title: Deploy Knot
weight: 30
---

```hcl
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
    }

    task "knot-server" {
      driver = "docker"
      config {
        image = "paularlott/knot:latest"
        ports = ["knot_port"]
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
  download_path: /srv
  url: "https://knot.getknot.dev"
  wildcard_domain: "*.knot.getknot.dev"
  encrypt: "knot genkey"
  location: core

  redis:
    enabled: true
    hosts:
      - redis.service.consul:6379
    password: ""
    db: 0

  nomad:
      addr: "http://{{ env "NOMAD_IP_knot_port" }}:4646"
      token: ""

resolver:
  consul:
    - {{ env "NOMAD_IP_knot_port" }}:8600

  nameservers:
    - 1.1.1.1
    - 1.0.0.1
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
    }
  }
}
```

Deploy the knot server:

```shell
nomad run knot.hcl
```
