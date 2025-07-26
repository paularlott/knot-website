---
title: Valkey
weight: 30
---

The following defines a template and when deployed runs an instance of a Valkey server, the space has no persistent storage so restarting it will destroy the current data.

```hcl {filename=Nomad-Job}
job "${{.user.username}}-${{.space.name}}" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert      = true
  }

  group "valkey" {
    count = 1

    network {
      port "valkey_port" {
        to = 6379
      }
    }

    task "valkey" {
      env {
        # Define environment variables for agent
        KNOT_SERVER         = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT = "${{.server.agent_endpoint}}"
        KNOT_SPACEID        = "${{.space.id}}"
        KNOT_TCP_PORT       = "6379"
        KNOT_USER           = "redis"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-valkey:latest"

        ports = ["valkey_port"]

        hostname = "${{ .space.name }}"

        # Only required if we're exposing the redis port to the outside world
        args = ["--bind", "0.0.0.0"]
      }

      resources {
        cpu = 300
        memory = 512
      }

      # Redis Port
      service {
        name = "${{.user.username}}-${{.space.name}}"
        port = "valkey_port"

        check {
          name     = "valkey_check"
          type     = "tcp"
          interval = "10s"
          timeout  = "5s"
        }
      }

    }
  }
}
```

The space exports the Valkey port 6379 via the TCP proxy so that it can be connected to via [port forwarding](/docs/spaces/port-forwarding) within the desktop client e.g.

```shell
knot forward port 127.0.0.1:6379 user-valkey 6379
```

Once the above command is running any desktop Redis / Valkey client should be able to connect to port 6379 on the localhost, knot will take care of forwarding the data to the Valkey server running within the space.

It also exposes the port via the service so that it can be accessed via the public IP address of the space.
