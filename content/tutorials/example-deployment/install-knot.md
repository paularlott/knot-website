---
title: Install Knot
weight: 40
---

Follow the [Initial User Setup](../../getting-started/initial-user/)

## Create a Template

Then create an `Ubuntu` template:

```hcl
job "${{.user.username}}-${{.space.name}}" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = false
  }

  group "ubuntu" {
    count = 1

    task "ubuntu" {
      env {
        # Define environment variables for agent
        KNOT_SERVER         = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT = "${{.server.agent_endpoint}}"
        KNOT_SPACEID        = "${{.space.id}}"
        KNOT_LOGLEVEL       = "warn"
        KNOT_USER           = "${{.user.username}}"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-ubuntu:24.04"

        hostname = "${{ .space.name }}"

        cap_add = [
          "NET_RAW" # Needed for ping to work
        ]
      }

      resources {
        cpu = 300
        memory = 512
      }
    }
  }
}
```

{{< tip >}}
  If your domain is accessed via internal name servers rather than public nameservers then the environment variable `KNOT_NAMESERVERS` will need to be updated to list the IPs of the internal nameservers.
{{< /tip >}}

At this point a space can be created from the template as described in the [Working with Spaces](../../spaces/) guide.
