---
title: Install Knot
weight: 40
---

Follow the [Initial User Setup](../initial-user)

Then create a `debian` template:

```hcl
job "${{.user.username}}-${{.space.name}}" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = false
  }

  group "debian" {
    count = 1

    network {
      port "knot_port" {
        to = 3000
      }
    }

    task "debian" {
      env {
        # Define environment variables for agent
        KNOT_SERVER = "${{.server.url}}"
        KNOT_SPACEID = "${{.space.id}}"
        KNOT_LOGLEVEL = "warn"
        KNOT_USER = "${{.user.username}}"

        KNOT_DNS_LISTEN = "127.0.0.1:53"
        KNOT_CONSUL_SERVERS = "${attr.unique.network.ip-address}:8600"
        KNOT_NAMESERVERS = "1.1.1.1 1.0.0.1"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-debian:12"

        ports = ["knot_port"]
        hostname = "${{ .space.name }}"

        cap_add = [
          "NET_RAW" # Needed for ping to work
        ]
      }

      resources {
        cpu = 300
        memory = 512
      }

      # Knot Agent Port
      service {
        name = "knot-${{.space.id}}"
        port = "knot_port"
        address = "${attr.unique.network.ip-address}"

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

    }
  }
}
```

{{< callout type="info" >}}
  If your domain is accessed via internal name servers rather than public nameservers then the environment variable `KNOT_NAMESERVERS` will need to be updated to list the IPs of the internal nameservers.
{{< /callout >}}

At this point a space can be created from the template and deployed.
