---
title: Redis
weight: 50
---

The following defines a space which runs an instance of a Redis server, the space has no persistent storage so restarting it will destroy the current data.

```hcl {filename=Nomad-Job}
job "${{.user.username}}-${{.space.name}}" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert      = true
  }

  group "redis" {
    count = 1

    network {
      port "knot_port" {
        to = 3000
      }
      port "redis_port" {
        to = 6379
      }
    }

    task "redis" {
      env {
        # Define environment variables for agent
        KNOT_SERVER   = "${{.server.url}}"
        KNOT_SPACEID  = "${{.space.id}}"
        KNOT_TCP_PORT = "6379"
        KNOT_USER     = "redis"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-redis:7.2"

        ports = ["knot_port", "redis_port"]

        hostname = "${{ .space.name }}"
      }

      resources {
        cpu = 300
        memory = 512
      }

      # Knot Agent Port
      service {
        name = "knot-${{.space.id}}"
        port = "knot_port"

        check {
          name            = "alive"
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/ping"
          interval        = "10s"
          timeout         = "2s"
        }
      }

      # Redis Port
      service {
        name = "${{.user.username}}-${{.space.name}}"
        port = "redis_port"

        check {
          name     = "redis_check"
          type     = "tcp"
          interval = "10s"
          timeout  = "5s"
        }
      }

    }
  }
}
```

The space exports the Redis port 6379 via the TCP proxy so that it can be connected to via [port forwarding](/docs/working-with-spaces/port-forwarding) within the desktop client e.g.

```shell
knot forward port 127.0.0.1:6379 myredis 6379
```

Once the above command is running any desktop Redis client should be able to connect to port 6379 on the localhost, knot will take care of forwarding the data to the Redis server running within the space.
